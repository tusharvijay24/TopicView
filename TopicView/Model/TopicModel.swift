//
//  TopicModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation

struct TopicModel: Hashable, Identifiable {
    let id: Int
    let name: String
    let subtopicRange: ClosedRange<Int>
    let zipURL: URL
}


