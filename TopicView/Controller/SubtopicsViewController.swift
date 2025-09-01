//
//  SubtopicsViewController.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import UIKit
final class SubtopicsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var vm: SubtopicsViewModel!
       @IBOutlet weak var tblSubtopics: UITableView!
       
       override func viewDidLoad() {
           super.viewDidLoad()
           title = vm.topic.name // Add navigation title
           tblSubtopics.dataSource = self
           tblSubtopics.delegate = self
           tblSubtopics.reloadData()
       }
       
       func configure(with topic: TopicModel) {
           self.vm = SubtopicsViewModel(topic: topic)
       }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.subtopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtopicCell", for: indexPath) as! SubtopicCell
        cell.textLabel?.text = vm.subtopics[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subtopic = vm.subtopics[indexPath.row]
        let vc = ImageViewController(subtopic: subtopic)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

