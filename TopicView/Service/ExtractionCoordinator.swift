//
//  ExtractionCoordinator.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation

final class ExtractionCoordinator {
    private let unzip = UnzipService()
    
    func extractTopicZip(topicId: Int, from zipURL: URL) throws {
        let dest = FilePaths.topicDir(topicId: topicId)
       
        if FileManager.default.fileExists(atPath: dest.path) {
            try FileManager.default.removeItem(at: dest)
        }
        
        // Create destination directory
        try FileManager.default.createDirectory(at: dest, withIntermediateDirectories: true, attributes: nil)
        
        try unzip.extract(zipAt: zipURL, to: dest, progress: nil)
      
        if let files = try? FileManager.default.contentsOfDirectory(atPath: dest.path) {
          
            // Filter image files
            let imageFiles = files.filter { file in
                let lowercased = file.lowercased()
                return lowercased.hasSuffix(".png") || lowercased.hasSuffix(".jpg") || lowercased.hasSuffix(".jpeg")
            }
         
            // Check if there are subdirectories
            for file in files {
                let filePath = dest.appendingPathComponent(file)
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: filePath.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    if let subFiles = try? FileManager.default.contentsOfDirectory(atPath: filePath.path) {
                        print("📁 Contents of \(file): \(subFiles)")
                    }
                }
            }
        }
        
        try? FileManager.default.removeItem(at: zipURL)
        print("🗑️ Cleaned up zip file")
    }
}
