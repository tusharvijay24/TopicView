//
//  UnzipService.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import Foundation
import ZIPFoundation

final class UnzipService {
    func extract(zipAt zipURL: URL, to destination: URL, progress: Progress? = nil) throws {
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try FileManager.default.unzipItem(at: zipURL, to: destination, progress: progress)
    }
}
