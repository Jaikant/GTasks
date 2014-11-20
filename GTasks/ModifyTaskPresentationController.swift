//
//  ThePresentationController.swift
//  PresentationControllerBoilerPlate
//
//  Created by Jai on 02/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class ModifyTaskPresentationController: UIPresentationController {
    
    var dimview : UIView?
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
    }
    
    func configureAttributedTextSystemButton(attributedTextButton: UIButton) {
        let buttonTitle = NSLocalizedString("Dismiss", comment: "")
        
        // Set the button's title for normal state.
        let normalTitleAttributes = [
            NSForegroundColorAttributeName: UIColor.applicationBlueColor()
        ]
        let normalAttributedTitle = NSAttributedString(string: buttonTitle, attributes: normalTitleAttributes)
        attributedTextButton.setAttributedTitle(normalAttributedTitle, forState: .Normal)
        
        // Set the button's title for highlighted state.
        let highlightedTitleAttributes = [
            NSForegroundColorAttributeName: UIColor.greenColor(),
            NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleThick.rawValue
        ]
        let highlightedAttributedTitle = NSAttributedString(string: buttonTitle, attributes: highlightedTitleAttributes)
        attributedTextButton.setAttributedTitle(highlightedAttributedTitle, forState: .Highlighted)
        
        attributedTextButton.addTarget(self, action: "dismissTasklistController", forControlEvents: .TouchUpInside)
    }
    
    func dismissTasklistController() {
        presentedViewController.dismissViewControllerAnimated(true, completion: {})
    }
    
    
    override func presentationTransitionWillBegin() {
        
        //var dimViewframe =  CGRect(origin: CGPoint(x: CGRectGetMaxX(containerView.bounds)*0.0, y: CGRectGetMaxY(containerView.bounds)*0.0), size: CGSize(width: containerView.bounds.width * 1.0, height: containerView.bounds.height * 0.9))
        
        
        dimview = UIView(frame: containerView.bounds)
        self.containerView.addSubview(dimview!)
        dimview?.backgroundColor = UIColor.blackColor()
        dimview?.alpha = 0.0
        
        var frame =  CGRect(origin: CGPoint(x: CGRectGetMaxX(containerView.bounds)*0.0, y: CGRectGetMaxY(containerView.bounds)*0.9), size: CGSize(width: containerView.bounds.width * 1.0, height: containerView.bounds.height * 0.1))
        
        var dismissButton = UIButton(frame: frame)
        configureAttributedTextSystemButton(dismissButton)
        dismissButton.backgroundColor = UIColor.whiteColor()
        dismissButton.alpha = 1.0
        self.containerView.addSubview(dismissButton)
        
        let transCoord = self.presentingViewController.transitionCoordinator()
        transCoord?.animateAlongsideTransitionInView(dimview!, animation: {(context)-> Void in self.dimview!.alpha = 0.8
            dismissButton.alpha = 1.0 }, completion: {(context)->Void in ()})
        
        
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
        var frame =  CGRect(origin: CGPoint(x: CGRectGetMaxX(containerView.bounds)*0.1, y: CGRectGetMaxY(containerView.bounds)*0.10), size: CGSize(width: containerView.bounds.width * 0.8, height: containerView.bounds.height * 0.70))
        
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        var vw = self.presentedView()
        vw.frame = frameOfPresentedViewInContainerView()
        
        dimview?.frame = self.containerView.frame
    }
    
}


