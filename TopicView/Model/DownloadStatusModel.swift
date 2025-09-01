//
//  DownloadStatusModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation

enum DownloadStatusModel: Equatable, Hashable {
    case notStarted
    case queued
    case downloading(progress: Double)
    case extracting
    case completed
    case failed(String)
}






