//
//  ImageViewModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import UIKit
final class ImageViewModel {
    func localImageURL(for subtopic: SubtopicModel) -> URL {
        FilePaths.imageURL(topicId: subtopic.topicId,
                           fileName: subtopic.imageFileName)
    }
    
    func loadImage(for subtopic: SubtopicModel) -> UIImage? {
        let imageURL = localImageURL(for: subtopic)
       
        // Check if file exists
        if FileManager.default.fileExists(atPath: imageURL.path) {
       
            let image = UIImage(contentsOfFile: imageURL.path)
            return image
        } else {
           
            let topicDir = FilePaths.topicDir(topicId: subtopic.topicId)
            if let files = try? FileManager.default.contentsOfDirectory(atPath: topicDir.path) {
                print("📁 Files in topic directory: \(files)")
                
                // Try to find image with different extensions or naming patterns
                let possibleNames = [
                    "image-\(subtopic.id).png",
                    "image-\(subtopic.id).jpg",
                    "image-\(subtopic.id).jpeg",
                    "\(subtopic.id).png",
                    "\(subtopic.id).jpg"
                ]
                
                for name in possibleNames {
                    if files.contains(name) {
                        print("🔍 Found alternative image: \(name)")
                        let alternativeURL = topicDir.appendingPathComponent(name)
                        return UIImage(contentsOfFile: alternativeURL.path)
                    }
                }
            }
            
            return nil
        }
    }
}
