//
//  ImageViewController.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import UIKit

final class ImageViewController: UIViewController {
    
    private let subtopic: SubtopicModel
    private let vm = ImageViewModel()
    private let imageView = UIImageView()
    private let errorLabel = UILabel()
    
    init(subtopic: SubtopicModel) {
       
        self.subtopic = subtopic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImage()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = subtopic.name
        
        // Setup image view
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Setup error label
        errorLabel.text = "Please download the images Or Image not available"
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 16)
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadImage() {
        showLoader(text: "Loading image...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.vm.loadImage(for: self.subtopic)
            
            DispatchQueue.main.async {
                self.hideLoader()
                
                if let image = image {
                    self.imageView.image = image
                    self.errorLabel.isHidden = true
                } else {
                    self.errorLabel.isHidden = false
                    self.imageView.image = nil
                }
            }
        }
    }
    
   
}
