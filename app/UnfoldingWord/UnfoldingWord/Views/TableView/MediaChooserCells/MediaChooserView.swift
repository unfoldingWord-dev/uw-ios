//
//  MediaChooserView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/24/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

class MediaChooserView: UIView {

    @IBOutlet weak var imageViewType: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonCheckingLevel: UIButton!
    @IBOutlet weak var buttonCheckmark: UIButton!

    var isChecked = false {
        didSet {
            let image = isChecked ? Constants.ImageName.checkInBox : Constants.ImageName.checklessBox
            buttonCheckmark.setBackgroundImage(UIImage(named: image), forState: UIControlState.Normal)
        }
    }
    var checkmarkMarkBlock : ButtonPressBlock? = nil
    var checkingLevelBlock : ButtonPressBlock? = nil
    
    static func createWithType(type : MediaType) -> MediaChooserView
    {
        let view = UINib.viewForName(NSStringFromClass(MediaChooserView).textAfterLastPeriod()) as! MediaChooserView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setType(type)
        return view
    }
    
    // Custom getter and setter because of some issue with the Swift headers. Ideally this would just be an plain var called type.
    private var internalType : MediaType = .Text
    
    func setType(type : MediaType) {
        internalType = type
        updateLabel()
    }
    
    func getType() -> MediaType {
        return internalType
    }
    
    @IBAction func userPressedCheckMarkButton(sender: UIButton) {
        isChecked = !isChecked
        fire(checkmarkMarkBlock)
    }
    
    @IBAction func userPressedCheckingLevelButton(sender: UIButton) {
        fire(checkingLevelBlock)
    }
    
    
    private func fire(block : ButtonPressBlock?) {
        guard let block = block else {
            assertionFailure("No outlet for button!")
            return }
        block()
    }
    
    private func updateLabel() {
        switch internalType {
        case .Text:
            labelDescription.text = "Text"
        case .Audio:
            labelDescription.text = "Audio"
        case .Video:
            labelDescription.text = "Video"
        case .None:
            assertionFailure("Created a choose view with no type.")
            labelDescription.text = "Error!"
        }
    }
    
}
