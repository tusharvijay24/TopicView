//
//  SubtopicModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation

struct SubtopicModel: Hashable, Identifiable {
    let id: Int
    let name: String
    let imageFileName: String
    let topicId: Int
}
