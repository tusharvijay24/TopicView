//
//  DownloadCell.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import UIKit

final class DownloadCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vwProgress: UIProgressView!
    @IBOutlet weak var lblStatus: UILabel!

    private var onStart: (() -> Void)?
    private var onPause: (() -> Void)?
    private var onResume: (() -> Void)?
    private var onCancel: (() -> Void)?

    func configure(item: DownloadItemModel,
                   onStart: @escaping ()->Void,
                   onPause: @escaping ()->Void,
                   onResume: @escaping ()->Void,
                   onCancel: @escaping ()->Void) {
        lblTitle.text = item.topic.name
        self.onStart = onStart
        self.onPause = onPause
        self.onResume = onResume
        self.onCancel = onCancel
        
        switch item.status {
        case .notStarted:
            lblStatus.text = "Not started"
            vwProgress.setProgress(0, animated: false)
        case .queued:
            lblStatus.text = "Queued"
            vwProgress.setProgress(0, animated: false)
        case .downloading(let p):
            lblStatus.text = String(format: "%.0f%%", p * 100)
            // Use animated progress updates for smoother transitions
            vwProgress.setProgress(Float(p), animated: true)
        case .extracting:
            lblStatus.text = "Extracting…"
            vwProgress.setProgress(1, animated: true)
        case .completed:
            lblStatus.text = "Completed"
            vwProgress.setProgress(1, animated: true)
        case .failed(let e):
            lblStatus.text = "Failed: \(e)"
            vwProgress.setProgress(0, animated: false)
        }
    }

    @IBAction func startTapped() {
        onStart?()
    }
    
    @IBAction func pauseTapped() {
        onPause?()
    }
    
}
