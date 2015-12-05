//
//  CheckChoiceView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/1/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import UIKit

class CheckChoiceView: UIView {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    
    var type : MediaType = .None {
        didSet {
            switch type {
            case .Text:
                label.text = "Text"
                self.userInteractionEnabled = false
                self.selected = true
            case .Audio:
                label.text = "Audio"
                self.selected = false
            case .Video:
                label.text = "Video"
                self.selected = false
            case .None:
                assertionFailure("Can't set no media type!")
            }
        }
    }
    
    var selected = false {
        didSet {
            let imagename : String
            if type == .Text {
                 imagename = Constants.ImageName.checkBoxFixedOn
            } else {
                imagename = selected ? Constants.ImageName.checkInBox : Constants.ImageName.checklessBox
            }
            
            imageView.image = UIImage(named: imagename)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func createWithType(type : MediaType) -> CheckChoiceView {
        let view = UINib.viewForName(NSStringFromClass(CheckChoiceView).textAfterLastPeriod()) as! CheckChoiceView
        view.type = type
        return view
    }
        
    @IBAction func userPressedView(sender: AnyObject) {
        selected = !selected
    }
}
