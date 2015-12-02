//
//  UIViewController+Dialog.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/30/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    func showDialog(dialog : UIView) -> DialogBackgroundView? {
        guard let window = getWindow() else { return nil }
        dialog.frame.size = dialog.systemLayoutSizeFittingSize(window.frame.size)
        let background = DialogBackgroundView(frame: CGRectMake(0,0,1,1))
        window.addSubview(background)
        window.bringSubviewToFront(background)
        window.addConstraints(background.constraintsToBox(inside: window, withMarginsAllSides: 0))
        window.layoutIfNeeded()
        background.layoutIfNeeded()
        
        background.animateInDialogView(dialog) { () -> Void in }
        return background
    }
    
    func animateOutDialog() {
        guard let window = getWindow() else { return }
        let backgroundArray = window.subviews.filter { $0 is DialogBackgroundView }
        guard let background = backgroundArray.first as? DialogBackgroundView where backgroundArray.count == 1 else {
            assertionFailure("No dialog to animate out!")
            return
        }
        background.animateOutDialog({  () -> () in
            background.removeFromSuperview()
        })
    }
    
    private func getWindow() -> UIWindow? {
        guard let
            appDelegate = UIApplication.sharedApplication().delegate,
            window = appDelegate.window!
            else {
                assertionFailure("Could not get the app's window!")
                return nil
        }
        return window
    }
    
}