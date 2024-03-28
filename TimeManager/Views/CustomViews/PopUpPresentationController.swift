//
//  PopOpPresentationController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 27.03.2024.
//

import UIKit

internal final class PopUpPresentationController: UIPresentationController {
    public var divider = 2.5
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerViewBounds = containerView?.bounds else { return .zero }
        let height = containerViewBounds.height / divider
        return CGRect(x: 0, y: containerViewBounds.height - height, width: containerViewBounds.width, height: height)
    }
}

