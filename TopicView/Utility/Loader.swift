//
//  Loader.swift
//  TopicView
//
//  Created by Tushar Vijayvargiya on 02/09/25.
//


import UIKit

public final class Loader {
    
    public static let shared = Loader()

    private let overlays = NSMapTable<UIView, UIView>(keyOptions: .weakMemory, valueOptions: .weakMemory)

    private init() { }

    @discardableResult
    public func show(on view: UIView,
                     text: String? = nil,
                     style: UIActivityIndicatorView.Style = .large) -> UIView {

        if let existing = overlays.object(forKey: view) { return existing }

        let overlay = UIView(frame: view.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        overlay.isUserInteractionEnabled = true // block touches behind

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 14
        blur.clipsToBounds = true
        overlay.addSubview(blur)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(stack)

        let spinner = UIActivityIndicatorView(style: style)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        stack.addArrangedSubview(spinner)

        if let text, !text.isEmpty {
            let label = UILabel()
            label.text = text
            label.textAlignment = .center
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.textColor = .label
            stack.addArrangedSubview(label)
        }

        view.addSubview(overlay)

        // Layout
        NSLayoutConstraint.activate([
            blur.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            blur.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            blur.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            stack.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -16)
        ])

        overlays.setObject(overlay, forKey: view)
        return overlay
    }

    public func hide(from view: UIView, animated: Bool = true) {
        guard let overlay = overlays.object(forKey: view) else { return }
        overlays.removeObject(forKey: view)
        if animated {
            UIView.animate(withDuration: 0.2, animations: { overlay.alpha = 0 }) { _ in
                overlay.removeFromSuperview()
            }
        } else {
            overlay.removeFromSuperview()
        }
    }
}


public extension UIViewController {
    func showLoader(text: String? = nil) {
        Loader.shared.show(on: view, text: text, style: .large)
    }
    func hideLoader() {
        Loader.shared.hide(from: view, animated: true)
    }
}
