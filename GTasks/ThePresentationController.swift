//
//  ThePresentationController.swift
//  PresentationControllerBoilerPlate
//
//  Created by Jai on 02/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class ThePresentationController: UIPresentationController {
    
    var dimview : UIView?
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        LogError.log("4")
        
    }
    
    
    override func presentationTransitionWillBegin() {
        
        dimview = UIView(frame: containerView.bounds)
        self.containerView.addSubview(dimview!)
        dimview?.backgroundColor = UIColor.darkGrayColor()
        dimview?.alpha = 0.0
        let transCoord = self.presentingViewController.transitionCoordinator()
        transCoord?.animateAlongsideTransitionInView(dimview!, animation: {(context)-> Void in self.dimview!.alpha = 0.6}, completion: {(context)->Void in ()})
        
        
    }
    
    override func dismissalTransitionWillBegin() {
        var transCoord = self.presentingViewController.transitionCoordinator()
        transCoord?.animateAlongsideTransitionInView(dimview, animation: {(context)-> Void in self.dimview!.alpha = 0.0}, completion: {(context)->Void in ()})
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed == true {
            dimview?.removeFromSuperview()
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        if completed == false {
            self.dimview?.removeFromSuperview()
        }
    }
    
    
    /*override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    var sizeSecondary = CGSize(width: containerView.bounds.width, height: containerView.bounds.height)
    LogError.log("1")
    
    return sizeSecondary
    }*/
    
    
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var frame =  CGRect(origin: CGPoint(x: CGRectGetMaxX(containerView.bounds)*0.0, y: CGRectGetMaxY(containerView.bounds)*0.0), size: CGSize(width: containerView.bounds.width * 1.0, height: containerView.bounds.height * 1.0))

        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        var vw = self.presentedView()
        vw.frame = frameOfPresentedViewInContainerView()
        
        dimview?.frame = self.containerView.frame
    }
    
}


