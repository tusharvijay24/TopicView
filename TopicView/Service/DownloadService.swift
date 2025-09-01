//
//  DownloadService.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//

import Foundation

protocol DownloadServiceDelegate: AnyObject {
    func downloadProgress(topicId: Int, progress: Double)
    func downloadFinished(topicId: Int, fileURL: URL)
    func downloadFailed(topicId: Int, error: String)
    func allBackgroundEventsComplete()
}

enum Networking {
   
    static let backgroundSessionIdentifier: String = {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.example.app"
        return bundleID + ".bg-downloads"
    }()

    static let timeout: TimeInterval = 60 * 60 // 1 hour for large archives
    static let httpMaximumConnectionsPerHost: Int = 4
    static let waitsForConnectivity: Bool = true
    static let isDiscretionary: Bool = false
}

final class DownloadService: NSObject {
    static let shared = DownloadService()

    private let sessionIdentifier = Bundle.main.bundleIdentifier! + ".bg-downloads"
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 4
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    weak var delegate: DownloadServiceDelegate?

    private var taskToTopic: [Int: Int] = [:]
    private var resumeDataForTopic: [Int: Data] = [:]
    private var activeTopics: Set<Int> = [] // ✅ Track active downloads
    private let syncQueue = DispatchQueue(label: "DownloadService.sync")
    private var backgroundCompletionHandler: (() -> Void)?

    func setBackgroundCompletionHandler(_ handler: @escaping () -> Void) {
        syncQueue.async { self.backgroundCompletionHandler = handler }
    }

    func startDownload(for topic: TopicModel) {
        syncQueue.async {
            // ✅ Check if already downloading
            guard !self.activeTopics.contains(topic.id) else {
                print("⚠️ Download already active for topic: \(topic.id)")
                return
            }
            
            self.activeTopics.insert(topic.id)
            
            DispatchQueue.main.async {
                let req = URLRequest(url: topic.zipURL,
                                   cachePolicy: .reloadIgnoringLocalCacheData,
                                   timeoutInterval: 3600)
                let task = self.session.downloadTask(with: req)
                
                self.syncQueue.async {
                    self.taskToTopic[task.taskIdentifier] = topic.id
                }
                
                task.resume()
                print("✅ Started download for topic: \(topic.id)")
            }
        }
    }

    func pause(topicId: Int) {
        syncQueue.async {
            guard self.activeTopics.contains(topicId),
                  let taskId = self.taskToTopic.first(where: { $0.value == topicId })?.key else {
                return
            }
            
            self.session.getAllTasks { tasks in
                (tasks.first(where: { $0.taskIdentifier == taskId }) as? URLSessionDownloadTask)?
                    .cancel(byProducingResumeData: { data in
                        if let d = data {
                            self.resumeDataForTopic[topicId] = d
                        }
                        // ✅ Remove from active topics when paused
                        self.syncQueue.async {
                            self.activeTopics.remove(topicId)
                        }
                    })
            }
        }
    }

    func resume(topic: TopicModel) {
        syncQueue.async {
            // ✅ Check if already downloading
            guard !self.activeTopics.contains(topic.id) else {
                print("⚠️ Resume ignored - already downloading topic: \(topic.id)")
                return
            }
            
            self.activeTopics.insert(topic.id)
            
            if let data = self.resumeDataForTopic[topic.id] {
                DispatchQueue.main.async {
                    let task = self.session.downloadTask(withResumeData: data)
                    self.syncQueue.async {
                        self.taskToTopic[task.taskIdentifier] = topic.id
                        self.resumeDataForTopic.removeValue(forKey: topic.id)
                    }
                    task.resume()
                    print("✅ Resumed download for topic: \(topic.id)")
                }
            } else {
                // Start fresh download
                DispatchQueue.main.async {
                    self.startDownload(for: topic)
                }
            }
        }
    }

    func cancel(topicId: Int) {
        syncQueue.async {
            guard let taskId = self.taskToTopic.first(where: { $0.value == topicId })?.key else {
                return
            }
            
            self.session.getAllTasks { tasks in
                tasks.first(where: { $0.taskIdentifier == taskId })?.cancel()
            }
            
            // ✅ Clean up everything
            self.taskToTopic.removeValue(forKey: taskId)
            self.resumeDataForTopic.removeValue(forKey: topicId)
            self.activeTopics.remove(topicId)
        }
    }
    
    // ✅ Helper method to check if download is active
    func isDownloadActive(for topicId: Int) -> Bool {
        return syncQueue.sync { activeTopics.contains(topicId) }
    }
}

extension DownloadService: URLSessionDownloadDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let topicId = syncQueue.sync { taskToTopic[downloadTask.taskIdentifier] }
        
        if let topicId = topicId {
            DispatchQueue.main.async {
                self.delegate?.downloadProgress(topicId: topicId, progress: progress)
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let topicId = syncQueue.sync(execute: { taskToTopic[downloadTask.taskIdentifier] }) else { return }
        
        let dst = FilePaths.tempZipURL(topicId: topicId)
        try? FileManager.default.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: dst)
        
        do {
            try FileManager.default.moveItem(at: location, to: dst)
            DispatchQueue.main.async {
                self.delegate?.downloadFinished(topicId: topicId, fileURL: dst)
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.downloadFailed(topicId: topicId, error: error.localizedDescription)
            }
        }
        
        // ✅ Remove from active topics when finished
        syncQueue.async {
            self.activeTopics.remove(topicId)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let topicId = syncQueue.sync(execute: { taskToTopic[task.taskIdentifier] }) else { return }
        
        if let err = error as NSError?, err.code != NSURLErrorCancelled {
            DispatchQueue.main.async {
                self.delegate?.downloadFailed(topicId: topicId, error: err.localizedDescription)
            }
        }
        
        // ✅ Clean up everything
        syncQueue.async {
            self.taskToTopic.removeValue(forKey: task.taskIdentifier)
            self.activeTopics.remove(topicId)
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        let handler = syncQueue.sync { backgroundCompletionHandler }
        backgroundCompletionHandler = nil
        handler?()
        DispatchQueue.main.async { self.delegate?.allBackgroundEventsComplete() }
    }
}
