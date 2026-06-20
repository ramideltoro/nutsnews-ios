//
//  SafariView.swift
//  NutsNews
//

import SafariServices
import SwiftUI
import UIKit

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    var forceFullScreen = false

    func makeUIViewController(context: Context) -> UIViewController {
        if forceFullScreen {
            return FullScreenSafariContainerViewController(url: url)
        }

        return makeSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        // No update needed.
    }

    private func makeSafariViewController(url: URL) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.dismissButtonStyle = .close
        controller.preferredControlTintColor = UIColor(
            red: 0.96,
            green: 0.62,
            blue: 0.18,
            alpha: 1.0
        )
        return controller
    }
}

private final class FullScreenSafariContainerViewController: UIViewController, SFSafariViewControllerDelegate {
    private let safariViewController: SFSafariViewController

    init(url: URL) {
        safariViewController = SFSafariViewController(url: url)
        safariViewController.dismissButtonStyle = .close
        safariViewController.preferredControlTintColor = UIColor(
            red: 0.96,
            green: 0.62,
            blue: 0.18,
            alpha: 1.0
        )
        safariViewController.modalPresentationStyle = .fullScreen
        safariViewController.preferredContentSize = UIScreen.main.bounds.size
        super.init(nibName: nil, bundle: nil)
        safariViewController.delegate = self
        modalPresentationStyle = .fullScreen
        preferredContentSize = UIScreen.main.bounds.size
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        addChild(safariViewController)
        safariViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safariViewController.view)

        NSLayoutConstraint.activate([
            safariViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safariViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            safariViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            safariViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        safariViewController.didMove(toParent: self)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
