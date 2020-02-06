//
//  PhotoDetailViewController.swift
//  HEBBuddy
//
//  Created by Cervenka, Michelle on 12/10/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import UIKit

// TODO: Display the photo details.  I would like to use a StackView to display the image at the top and then the
// details below.
class PhotoDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var model: PhotoViewModel? {
        didSet {
            guard isViewLoaded else { return }

            if let url = model?.photoIfAny?.imageURL {
                imageDataTask = imageView.image(with: url)
            }
        }
    }

    private var imageDataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onDonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        imageDataTask?.cancel()
    }

    func initialize() {
        modalPresentationStyle = .custom
        view.isOpaque = false
        transitioningDelegate = self
    }

    deinit {
        imageDataTask?.cancel()
    }
}

extension PhotoDetailViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        return OverDimViewPresentationController(presentedViewController: presented, presenting: presenting)
    }

    public func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePushTransition(isPresenting: true)
    }

    public func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePushTransition(isPresenting: false)
    }
}
