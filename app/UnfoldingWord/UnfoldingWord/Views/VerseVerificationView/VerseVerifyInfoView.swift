//
//  VerseVerifyInfoView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/5/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import UIKit

class VerseVerifyInfoView: UIView {

    @IBOutlet weak var labelExplanation: UILabel!
    @IBOutlet weak var labelLevelInfo: UILabel!

    @IBOutlet weak var imageViewLevel: UIImageView!
    
    @IBOutlet var viewTextStatus: UIView!
    @IBOutlet var viewAudioStatus: UIView!
    @IBOutlet var viewVideoStatus: UIView!
    
    @IBOutlet var imageViewTextStatus: UIImageView!
    @IBOutlet var imageViewAudioStatus: UIImageView!
    @IBOutlet var imageViewVideoStatus: UIImageView!
    
    @IBOutlet var labelTextStatusDesc: UILabel!
    @IBOutlet var labelAudioStatusDesc: UILabel!
    @IBOutlet var labelVideoStatusDesc: UILabel!
    
    
    var version : UWVersion? = nil {
        didSet {
            labelExplanation.text = VERSION_INFO
            setCheckingLevel()
            setMediaValidationInfo()
        }
    }
    
    static func verifyViewForVersion(version : UWVersion) -> VerseVerifyInfoView {
        let verifyView = UINib.viewForName(NSStringFromClass(VerseVerifyInfoView).textAfterLastPeriod()) as! VerseVerifyInfoView
        verifyView.version = version
        verifyView.layer.cornerRadius = 9
        return verifyView
    }
    
    private func setMediaValidationInfo() {
        guard let version = version else { return }
        
        var topView : UIView = labelLevelInfo

        let textStatus = version.statusText()
        if (textStatus.contains(.Some)) {
            let textConst = NSLayoutConstraint.constraintsToFloatView(viewTextStatus, belowView: topView, padding: 8, withContainerView: self, leftMargin: 16, rightMargin: 16)
            self.addConstraints(textConst)
            topView = viewTextStatus
            
            if textStatus.contains(.AllValid) {
                imageViewAudioStatus.image = UIImage(named: IMAGE_VERIFY_GOOD)
                labelAudioStatusDesc.text = "Text is verified."
            } else {
                imageViewAudioStatus.image = UIImage(named: IMAGE_VERIFY_FAIL)
                labelAudioStatusDesc.text = "Text not verified."
            }
        } else {
            viewTextStatus.removeFromSuperview()
        }
        
        let audioStatus = version.statusAudio()
        if (audioStatus.contains(.Some)) {
            let audioConst = NSLayoutConstraint.constraintsToFloatView(viewAudioStatus, belowView: topView, padding: 8, withContainerView: self, leftMargin: 16, rightMargin: 16)
            self.addConstraints(audioConst)
            topView = viewAudioStatus
            
            if audioStatus.contains(.AllValid) {
                imageViewAudioStatus.image = UIImage(named: IMAGE_VERIFY_GOOD)
                labelAudioStatusDesc.text = "Audio is verified."
            } else {
                imageViewAudioStatus.image = UIImage(named: IMAGE_VERIFY_FAIL)
                labelAudioStatusDesc.text = "Audio not verified."
            }
        } else {
            viewAudioStatus.removeFromSuperview()
        }
        
        let videoStatus = version.statusVideo()
        if (videoStatus.contains(.Some)) {
            let videoConst = NSLayoutConstraint.constraintsToFloatView(viewVideoStatus, belowView: topView, padding: 8, withContainerView: self, leftMargin: 16, rightMargin: 16)
            self.addConstraints(videoConst)
            topView = viewVideoStatus
            
            if videoStatus.contains(.AllValid) {
                imageViewVideoStatus.image = UIImage(named: IMAGE_VERIFY_GOOD)
                labelVideoStatusDesc.text = "Video is verified."
            } else {
                imageViewVideoStatus.image = UIImage(named: IMAGE_VERIFY_FAIL)
                labelVideoStatusDesc.text = "Video not verified."
            }
        } else {
            viewVideoStatus.removeFromSuperview()
        }
        
        let bottomConstraint = topView.constraintAlignBottom(inside: self, constant: 16)
        self.addConstraint(bottomConstraint)
    
    }
    
    private func setCheckingLevel() {
        guard let version = version, status = version.status, level = status.checking_level, checking_level = Int(level)
            else {
                self.labelLevelInfo.text = "No checking level information was found!"
                imageViewLevel.image = UIImage(named: IMAGE_VERIFY_EXPIRE)
                assertionFailure("Setting an empty version/status/checking level doesn't make any sense.")
                return
        }
        imageViewLevel.image = imageForCheckingLevel(checking_level)
        self.labelLevelInfo.text = textForCheckingLevel(checking_level)

    }
    
    private func imageForCheckingLevel(level : Int) -> UIImage? {
        switch (level) {
        case 1:
            return UIImage(named: LEVEL_1_IMAGE)
        case 2:
            return UIImage(named: LEVEL_2_IMAGE)
        case 3:
            return UIImage(named: LEVEL_3_IMAGE)
        default:
            return UIImage(named: IMAGE_VERIFY_EXPIRE);
        }
    }
    
    private func textForCheckingLevel(level : Int) -> String? {
        switch (level) {
        case 1:
            return LEVEL_1_DESC
        case 2:
            return LEVEL_2_DESC
        case 3:
            return LEVEL_3_DESC
        default:
            return "No checking information was found.";
        }
    }
    
    
}
