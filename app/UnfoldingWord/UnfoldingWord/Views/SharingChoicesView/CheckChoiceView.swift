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
    
    var type : MediaType = .None
    
    var selected = false {
        didSet {
            let imagename = selected ? Constants.ImageName.checkInBox : Constants.ImageName.checklessBox
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
