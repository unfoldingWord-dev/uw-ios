//
//  FontSizePickerView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/23/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation

protocol FontSizeProtocol : class {
    func userDidChangeFontToSize(pointSize : CGFloat)
}

let arrayFontSizes : [CGFloat] = [13, 16, 19, 23, 27]

class FontSizePickerView : UIView {
    
    weak var delegate : FontSizeProtocol!
    
    class func pickerWithExistingSize(fontSize : CGFloat) -> FontSizePickerView {
        
        let nibViews = NSBundle.mainBundle().loadNibNamed("FontSizePickerView", owner: nil, options: nil)
        let pickerView = nibViews[0] as! FontSizePickerView
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }
    
    
    @IBAction func userDidChangeFontValue(slider: UISlider) {
        
        let numberOptions = Float(arrayFontSizes.count)
        let approxIndex : Float = (slider.value * (numberOptions - 1))
        let index = Int(round(approxIndex))
        
        delegate.userDidChangeFontToSize(arrayFontSizes[index])
        
        let adjustedValue : Float = (1 / (numberOptions-1)) * Float(index)
        slider.setValue(adjustedValue, animated: true)
    }
    
    
}