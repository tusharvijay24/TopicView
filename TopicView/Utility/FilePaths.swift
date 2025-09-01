//
//  FilePaths.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation
enum FilePaths {
    static var documents: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    static func topicDir(topicId: Int) -> URL {
        documents.appendingPathComponent("Topics/Topic\(topicId)", isDirectory: true)
    }

    static func tempZipURL(topicId: Int) -> URL {
        documents.appendingPathComponent("Zips/topic_\(topicId).zip")
    }

    static func imageURL(topicId: Int, fileName: String) -> URL {
        topicDir(topicId: topicId).appendingPathComponent(fileName)
    }
}


