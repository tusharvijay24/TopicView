//
//  TopicsViewModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation
final class TopicsViewModel {
    let topics: [TopicModel] = TopicRepository.allTopics()
}

