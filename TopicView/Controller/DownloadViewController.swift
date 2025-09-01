//
//  DownloadViewController.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//

import UIKit
import Combine

final class DownloadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let vm = DownloadsViewModel()
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var tblDownload: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    
    private func setupTableView() {
        tblDownload.dataSource = self
        tblDownload.delegate = self
        tblDownload.rowHeight = UITableView.automaticDimension
        tblDownload.estimatedRowHeight = 80
    }

    private func bindViewModel() {
        vm.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                
                // Only reload data if we're not currently reloading to prevent flickering
                if !self.tblDownload.isDragging && !self.tblDownload.isDecelerating {
                    self.tblDownload.reloadData()
                }

                // Show loader when any topic is extracting (indeterminate)
                let isExtracting = items.contains { item in
                    if case .extracting = item.status { return true }
                    return false
                }

                // Only show UI when app is active
                if UIApplication.shared.applicationState == .active {
                    if isExtracting {
                        self.showLoader(text: "Extracting images…")
                    } else {
                        self.hideLoader()
                    }
                }
            }
            .store(in: &cancellables)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath) as! DownloadCell
        let item = vm.items[indexPath.row]
        
        cell.configure(
            item: item,
            onStart: { [weak self] in
                self?.vm.start(topicId: item.topic.id)
            },
            onPause: { [weak self] in
                self?.vm.pause(topicId: item.topic.id)
            },
            onResume: { [weak self] in
                self?.vm.resume(topicId: item.topic.id)
            },
            onCancel: { [weak self] in
                self?.vm.cancel(topicId: item.topic.id)
            }
        )
        
        return cell
    }
    

}
