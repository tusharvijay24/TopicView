//
//  DownloadsViewModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//

import Foundation
import Combine
import UIKit

final class DownloadsViewModel: ObservableObject, DownloadServiceDelegate {
    private var progressUpdateTimers: [Int: Timer] = [:]
    private let updateInterval: TimeInterval = 0.1
    private var lastProgressValues: [Int: Double] = [:]
    
    @Published private(set) var items: [DownloadItemModel] = []
    
    private let extraction = ExtractionCoordinator()
    
    init(topics: [TopicModel] = TopicRepository.allTopics()) {
        self.items = topics.map { DownloadItemModel(topic: $0, status: .notStarted) }
        DownloadService.shared.delegate = self
        
        // App foreground में आने पर running downloads को restore करें
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restoreRunningDownloads),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        progressUpdateTimers.values.forEach { $0.invalidate() }
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func restoreRunningDownloads() {
        print("App came to foreground, checking for active downloads...")
    }
    
    func start(topicId: Int) {
        change(topicId, to: .queued)
        if let topic = topic(topicId) {
            DownloadService.shared.startDownload(for: topic)
        }
    }
    
    func pause(topicId: Int) {
        cleanupProgressTracking(for: topicId)
        DownloadService.shared.pause(topicId: topicId)
        change(topicId, to: .notStarted)
    }
    
    func resume(topicId: Int) {
        if let topic = topic(topicId) {
            change(topicId, to: .queued)
            DownloadService.shared.resume(topic: topic)
        }
    }
    
    func cancel(topicId: Int) {
        cleanupProgressTracking(for: topicId)
        DownloadService.shared.cancel(topicId: topicId)
        change(topicId, to: .notStarted)
    }
    
    // MARK: - DownloadServiceDelegate
    
    func downloadProgress(topicId: Int, progress: Double) {
        let lastProgress = lastProgressValues[topicId] ?? 0.0
        guard abs(progress - lastProgress) >= 0.005 else { return }
        
        lastProgressValues[topicId] = progress
        
        progressUpdateTimers[topicId]?.invalidate()
        
        progressUpdateTimers[topicId] = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: false) { [weak self] _ in
            self?.change(topicId, to: .downloading(progress: progress))
            self?.progressUpdateTimers.removeValue(forKey: topicId)
        }
    }
    
    func downloadFinished(topicId: Int, fileURL: URL) {
        cleanupProgressTracking(for: topicId)
        change(topicId, to: .extracting)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.extraction.extractTopicZip(topicId: topicId, from: fileURL)
                DispatchQueue.main.async {
                    self.change(topicId, to: .completed)
                    
                    // Local notification भेजें कि download complete हो गया
                    self.showDownloadCompletedNotification(for: topicId)
                }
            } catch {
                DispatchQueue.main.async {
                    self.change(topicId, to: .failed(error.localizedDescription))
                }
            }
        }
    }
    
    func downloadFailed(topicId: Int, error: String) {
        cleanupProgressTracking(for: topicId)
        change(topicId, to: .failed(error))
        
        // Error notification भेजें
        showDownloadFailedNotification(for: topicId, error: error)
    }
    
    func allBackgroundEventsComplete() {
        print("All background downloads completed")
    }
    
    // MARK: - Private Methods
    
    private func topic(_ id: Int) -> TopicModel? {
        items.first(where: { $0.topic.id == id })?.topic
    }
    
    private func change(_ id: Int, to status: DownloadStatusModel) {
        if let idx = items.firstIndex(where: { $0.topic.id == id }) {
            items[idx].status = status
            objectWillChange.send()
        }
    }
    
    private func cleanupProgressTracking(for topicId: Int) {
        progressUpdateTimers[topicId]?.invalidate()
        progressUpdateTimers.removeValue(forKey: topicId)
        lastProgressValues.removeValue(forKey: topicId)
    }
    
    private func showDownloadCompletedNotification(for topicId: Int) {
        guard let topic = topic(topicId) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Download Complete"
        content.body = "\(topic.name) has been downloaded successfully"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "download_complete_\(topicId)",
                                          content: content,
                                          trigger: nil)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func showDownloadFailedNotification(for topicId: Int, error: String) {
        guard let topic = topic(topicId) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Download Failed"
        content.body = "\(topic.name) download failed: \(error)"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "download_failed_\(topicId)",
                                          content: content,
                                          trigger: nil)
        
        UNUserNotificationCenter.current().add(request)
    }
}
