//
//  CustomAnimationPresenter.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/25/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit

class CustomAnimationPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //my custom transition animation code
        
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        containerView.addSubview(toView)
        
        let startingFrame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startingFrame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame =  CGRect(x: fromView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        
        }) { (_) in
            transitionContext.completeTransition(true)
        }
        
        transitionContext.completeTransition(true)
    }
}