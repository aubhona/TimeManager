//
//  PopOpPresentationController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 27.03.2024.
//

import UIKit

internal final class PopUpPresentationController: UIPresentationController {
    public var divider = 2.5
    private var dimmingView: UIView!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        configureDimmingView()
    }
    
    private func configureDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0.0
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        containerView.insertSubview(dimmingView, at: 0)
        
        dimmingView.pin(to: containerView)
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerViewBounds = containerView?.bounds else { return .zero }
        let height = containerViewBounds.height / divider
        return CGRect(x: 0, y: containerViewBounds.height - height, width: containerViewBounds.width, height: height)
    }
}
