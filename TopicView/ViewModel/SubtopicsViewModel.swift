//
//  SubtopicsViewModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation

final class SubtopicsViewModel {
    
    let topic: TopicModel
    let subtopics: [SubtopicModel]
    
    init(topic: TopicModel) {
        self.topic = topic
        self.subtopics = TopicRepository.subtopics(for: topic)
    }
}
