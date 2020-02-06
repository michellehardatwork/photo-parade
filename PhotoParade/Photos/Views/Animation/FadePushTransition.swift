//
//  FadePushTransition.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/6/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import UIKit

/// A Transition for pushing a view controller's content from the left or right, then reversing on dismissal.
public class FadePushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private let xOffset: CGFloat
    private let yOffset: CGFloat

    public init(isPresenting: Bool, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        self.isPresenting = isPresenting
        self.xOffset = xOffset
        self.yOffset = yOffset
        super.init()
    }

    public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        let controller = transitionContext.viewController(forKey: key)!

        let onscreenFrame = transitionContext.finalFrame(for: controller)
        let offscreenFrame = CGRect(x: xOffset, y: yOffset, width: onscreenFrame.width, height: onscreenFrame.height)

        let containerView = transitionContext.containerView

        if isPresenting {
            containerView.addSubview(controller.view)
        }

        controller.view.frame = isPresenting ? offscreenFrame : onscreenFrame
        controller.view.alpha = isPresenting ? 0 : 1
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        UIView.animate(timingFunction: TimingFunctions.e1Interpolator, withDuration: transitionDuration(using: transitionContext), animations: {
            controller.view.frame = self.isPresenting ? onscreenFrame : offscreenFrame
            controller.view.alpha = self.isPresenting ? 1 : 0
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

public struct TimingFunctions {
    public static var e1Interpolator: CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
    }

    public static var e2Interpolator: CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.1, 1.0)
    }

    public static var e3Interpolator: CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.0, 1.0)
    }
}

extension UIView {
    /// UIView.animate does not have any options for passing in a custom timing functions.
    /// Use this helper method to set the custom timing function prior to animating a view.
    ///
    /// - Parameters:
    ///   - timingFunction: the timing function to apply
    ///   - animationBlock: block wrapping your UIView.animate call or other transforms to
    ///                     animate with the timing function
    public static func transactionWithTimingFunction(_ timingFunction: CAMediaTimingFunction, _ animationBlock: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)
        animationBlock()
        CATransaction.commit()
    }

    /// Helper method to animate a view with a custom timing function.
    public static func animate(timingFunction: CAMediaTimingFunction,
                               withDuration duration: TimeInterval,
                               delay: TimeInterval = 0,
                               options: UIView.AnimationOptions = [],
                               animations: @escaping () -> Void,
                               completion: ((Bool) -> Void)? = nil) {
        transactionWithTimingFunction(timingFunction) {
            UIView.animate(withDuration: duration, delay: delay, options: options,
                           animations: animations, completion: completion)
        }
    }

    public func pushTransition(duration: CFTimeInterval, transitionSubType: CATransitionSubtype) {
        let animation: CATransition = CATransition()
        animation.timingFunction = TimingFunctions.e1Interpolator
        animation.type = CATransitionType.push
        animation.subtype = transitionSubType
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
}

