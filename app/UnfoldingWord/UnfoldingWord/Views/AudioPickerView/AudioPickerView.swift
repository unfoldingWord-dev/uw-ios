//
//  AudioPickerView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/30/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import UIKit

class AudioPickerView: UIView {
    
    let unselectedImage = "radio_button_empty.png"
    let selectedImage = "radio_button_filled.png"

    @IBOutlet weak var buttonLow: UIButton!
    @IBOutlet weak var buttonHigh: UIButton!

    var lowQuality = true
    var completionBlock : AudiQualitySelectionBlock? = nil
    
    class func create(completion : AudiQualitySelectionBlock ) -> AudioPickerView {
        let nibName = NSStringFromClass(self).textAfterLastPeriod()
        let instance = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil).first! as! AudioPickerView
        instance.completionBlock = completion
        instance.layer.cornerRadius = 10
        return instance
    }
    
    @IBAction func userTouchedQuality(button: UIButton) {
        lowQuality = button == buttonLow
        setButton(button, selected: true)
        let otherButton = button == buttonLow ? buttonHigh : buttonLow
        setButton(otherButton, selected: false)
    }

    @IBAction func userTouchedDownload(button: UIButton) {
        guard let block = completionBlock else {
            assertionFailure("No block for audio selection")
            return
        }
        block(isLowQuality: lowQuality)
        animateOutDialog()
    }
    
    private func setButton(button : UIButton, selected : Bool)
    {
        let imageName = selected ? selectedImage : unselectedImage
        button.setBackgroundImage(UIImage(named: imageName), forState: UIControlState.Normal)
        
    }
    
}
