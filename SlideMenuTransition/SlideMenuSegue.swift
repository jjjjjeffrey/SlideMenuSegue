//
//  SlideMenuSegue.swift
//  SlideMenuTransition
//
//  Created by zeng daqian on 16/4/27.
//  Copyright © 2016年 daqian. All rights reserved.
//

import UIKit

class SlideMenuSegue: UIStoryboardSegue {
    override func perform() {
        destinationViewController.transitioningDelegate = SlideMenuTransitoningManager.shareManager
        destinationViewController.modalPresentationStyle = .Custom
        sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
    }
}

class SlideMenuTransitoningManager: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate {
    
    static let shareManager = SlideMenuTransitoningManager()
    
    private override init() {}
    
    private var presenting = false
    private var interactive = false
    
    private var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    
    var sourceViewController: UIViewController? {
        didSet {
            self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action: #selector(self.handleOnstagePan(_:)))
            self.enterPanGesture.edges = UIRectEdge.Left
            self.sourceViewController?.view.addGestureRecognizer(self.enterPanGesture)
        }
    }
    

    func handleOnstagePan(pan: UIPanGestureRecognizer){
        
        let translation = pan.translationInView(pan.view!)
        
        
        let d =  translation.x / ((self.sourceViewController?.view.frame.width)!-100)
        
        
        
        switch (pan.state) {
            
        case UIGestureRecognizerState.Began:
            
            self.interactive = true
            
            self.sourceViewController?.performSegueWithIdentifier("presentMenu", sender: self)

            
        case UIGestureRecognizerState.Changed:
            
            self.updateInteractiveTransition(d)

            
        default:
            
            self.interactive = false
            self.finishInteractiveTransition()
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideMenuPresentAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideMenuDismissAnimator()
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return SlideMenuPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

extension SlideMenuTransitoningManager {
    
}

class SlideMenuPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return
        }
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return
        }
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        let animationDuration = self .transitionDuration(transitionContext)
        
        
        toViewController.view.frame = containerView.bounds
        toViewController.view.frame.size.width = containerView.bounds.width-100
        toViewController.view.frame.origin.x = -toViewController.view.frame.size.width
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            toViewController.view.frame.origin.x = 0
            fromViewController.view.frame.origin.x = containerView.bounds.width-100
            }, completion: { (finished) -> Void in
                transitionContext.completeTransition(finished)
                UIApplication.sharedApplication().keyWindow!.addSubview(fromViewController.view)
        })
    }
    
}

class SlideMenuDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let mainViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return
        }
        guard let menuViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return
        }
        
        let animationDuration = self .transitionDuration(transitionContext)
        
        
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            mainViewController.view.frame.origin.x = 0
            menuViewController.view.frame.origin.x = -menuViewController.view.frame.width
            }, completion: { (finished) -> Void in
                transitionContext.completeTransition(finished)

        })
    }
    
}

class SlideMenuPresentationController: UIPresentationController {
    
    lazy var blurView: UIVisualEffectView = {
       let v = UIVisualEffectView(frame: self.presentingViewController.view.bounds)
        v.effect = UIBlurEffect(style: .Light)
        v.alpha = 0.1
        return v
    }()
    
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        
        presentingViewController.view.addSubview(blurView)
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (transitionCoordinatorContext) in
            self.blurView.alpha = 1.0
            }, completion: { (transitionCoordinatorContext) in
                
        })
        
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (transitionCoordinatorContext) in
            self.blurView.alpha = 0.1
            }, completion: { (transitionCoordinatorContext) in
                self.blurView.removeFromSuperview()
        })
    }
    
    
}
