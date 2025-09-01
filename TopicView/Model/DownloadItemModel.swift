//
//  DownloadItemModel.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation

struct DownloadItemModel: Equatable, Hashable {
    let topic: TopicModel
    var status: DownloadStatusModel
}
