//
//  OverDimViewPresentationController.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/6/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import UIKit

/// A Presentation Controller that fades in a "Dim View" during transitions.
/// Use with presented view controllers that have transparency.
public class OverDimViewPresentationController: UIPresentationController {
    private let dimView = UIView()

    public override func presentationTransitionWillBegin() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        containerView?.addSubview(dimView)
        dimView.frame = containerView?.bounds ?? .zero
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 1.0
            return
        }

        dimView.alpha = 0.0
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 1.0
        }, completion: nil)
    }

    public override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 0.0
            return
        }

        dimView.alpha = 1.0
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 0.0
        }, completion: nil)
    }

    public override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

