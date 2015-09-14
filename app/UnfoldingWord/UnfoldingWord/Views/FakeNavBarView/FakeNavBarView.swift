//
//  FakeNavBarView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/14/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

class FakeNavBarView : UIView {
    
    @IBOutlet weak var buttonBackArrow: UIButton!
    
    @IBOutlet weak var labelButtonBookPlusChapter: ACTLabelButton!
    
    @IBOutlet weak var viewSSVersionContainer: UIView!
    @IBOutlet weak var labelButtonSSVersionMain: ACTLabelButton!
    @IBOutlet weak var labelButtonSSVersionSide: ACTLabelButton!
    
    @IBOutlet weak var labelButtonVersionMainAlone: ACTLabelButton!
    
    
    @IBOutlet weak var constaintDistanceSSContainerFromBook: NSLayoutConstraint!
    @IBOutlet weak var constraintDistanceBetweenSSVersions: NSLayoutConstraint!
    
}