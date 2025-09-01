//
//  TopicsViewController.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import UIKit

final class TopicsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let vm = TopicsViewModel()
    @IBOutlet weak var tblTopics: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblTopics.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath)
        cell.textLabel?.text = vm.topics[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblTopics.deselectRow(at: indexPath, animated: true)
        let topic = vm.topics[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SubtopicsViewController") as! SubtopicsViewController
        vc.configure(with: topic)
        navigationController?.pushViewController(vc, animated: true)
    }

}
