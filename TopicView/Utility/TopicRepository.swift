//
//  TopicRepository.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation

enum TopicRepository {
    static func allTopics() -> [TopicModel] {
        return [
            TopicModel(id: 1, name: "Topic1", subtopicRange: 201...400, zipURL: APIConstant.Topics.topic1URL),
            TopicModel(id: 2, name: "Topic2", subtopicRange: 401...706, zipURL: APIConstant.Topics.topic2URL)
        ]
    }
    
    static func subtopics(for topic: TopicModel) -> [SubtopicModel] {
        topic.subtopicRange.map { id in
            SubtopicModel(id: id,
                         name: "subtopic-\(id)",
                         imageFileName: "image-\(id).png", // Ensure this matches actual file names in zip
                         topicId: topic.id)
        }
    }
}

extension TopicRepository {
    static func isTopicDownloaded(topicId: Int) -> Bool {
        let topicDir = FilePaths.topicDir(topicId: topicId)
        return FileManager.default.fileExists(atPath: topicDir.path)
    }
    
    static func getDownloadedImageCount(for topicId: Int) -> Int {
        let topicDir = FilePaths.topicDir(topicId: topicId)
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: topicDir.path) else {
            return 0
        }
        return files.filter { $0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }.count
    }
}
