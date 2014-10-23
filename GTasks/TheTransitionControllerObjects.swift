//
//  TheTransitionControllerObjects.swift
//  GTasks
//
//  Created by Jai on 04/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import Foundation

class overlayTransitionDelegate : NSObject, UIViewControllerTransitioningDelegate {
    
    lazy var animationController: overlayAnimationObject? = {
        var _animationController = overlayAnimationObject()
        return _animationController }()

    override init() {
        super.init()
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        var presentationController = ThePresentationController(presentedViewController: presented, presentingViewController: presenting)
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController?.isPresentation = true
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController?.isPresentation = false
        return animationController
    }
    
    
}


class overlayAnimationObject : NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresentation : Bool?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
            animateForPresentation(transitionContext)
        
    }
    
    func animateForPresentation(transitionContext: UIViewControllerContextTransitioning) {
        
        var fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        var fromView = fromVC?.view
        
        var toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        var toView = toVC?.view
        
        
        var containerView = transitionContext.containerView()
        
        var isPresentation = self.isPresentation?
        
        if isPresentation == true {
            containerView.addSubview(toView!)
        }
        
        var animatingVC = isPresentation! ? toVC : fromVC
        var animatingView = animatingVC?.view
        
        var appearedFrame = transitionContext.finalFrameForViewController(animatingVC!)
        var dismissedFrame = appearedFrame
        
        dismissedFrame.origin.x = dismissedFrame.origin.x - dismissedFrame.size.width * 1.5
        
        var initialFrame = isPresentation! ? dismissedFrame : appearedFrame
        var finalFrame = isPresentation! ? appearedFrame : dismissedFrame
        
        animatingView?.frame = initialFrame
        
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 100.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.AllowUserInteraction, animations: { animatingView!.frame = finalFrame }, completion: {(finished : Bool) -> Void in
            if self.isPresentation == false {
                fromView?.removeFromSuperview() }
            transitionContext.completeTransition(true)})
        
    }
    
}
