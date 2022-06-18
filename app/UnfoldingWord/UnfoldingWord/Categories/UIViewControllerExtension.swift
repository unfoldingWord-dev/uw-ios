//
//  UIViewControllerExtension.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/21/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func addChildViewController(childVC : UIViewController, toView view : UIView) {
        
        childVC.willMove(toParent: self)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childVC.view)
        let constraints = NSLayoutConstraint.constraints(for: childVC.view, inside: view, topMargin: 0, bottomMargin: 0, leftMargin: 0, rightMargin: 0) as! [NSLayoutConstraint]
        view.addConstraints(constraints)
        self.addChild(childVC)
        childVC.didMove(toParent: self)
    }
}
