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

let arrayFontSizes : [CGFloat] = [13, 16, 18, 21, 28]

class FontSizePickerView : UIView {
    
    weak var delegate : FontSizeProtocol!
    
    @IBOutlet weak var sliderFontSizes: UISlider!
    
    @IBOutlet var lines: [UIView]!
    
    @IBOutlet weak var labelSmallText: UILabel!
    
    @IBOutlet weak var labelLargeText: UILabel!
    
    class func fontPicker() -> FontSizePickerView {
        
        let nibViews = NSBundle.mainBundle().loadNibNamed("FontSizePickerView", owner: nil, options: nil)
        let pickerView = nibViews[0] as! FontSizePickerView
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = BACKGROUND_GREEN()
        pickerView.adjustLineColors()
        pickerView.setIntialFontSizeShownOnPicker()
        return pickerView
    }
    
    func setIntialFontSizeShownOnPicker() {
        
        let size = UFWSelectionTracker.fontPointSize()
        if (size < 1) {
            self.setSliderToIndex(2, animated: false)
            return
        }
        
        for (index, listedSize) in arrayFontSizes.enumerate() {
            if size == listedSize {
                setSliderToIndex(index, animated: false)
                return
            }
        }
        assertionFailure("Could not find the font size \(size) in array \(arrayFontSizes)")
        setSliderToIndex(2, animated: false)
    }
    
    func adjustLineColors() {
        for (_ , view) in lines.enumerate() {
            view.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func adjustFonts() {
        labelSmallText.font = FONT_LIGHT().fontWithSize(arrayFontSizes.first!)
        labelLargeText.font = FONT_LIGHT().fontWithSize(arrayFontSizes.last!)
    }
    
    @IBAction func userDidChangeFontValue(slider: UISlider) {
        
        let numberOptions = Float(arrayFontSizes.count)
        let approxIndex : Float = (slider.value * (numberOptions - 1))
        let index = Int(round(approxIndex))
        setSliderToIndex(index, animated: true)
        UFWSelectionTracker.setFontPointSize(arrayFontSizes[index])
        
        delegate.userDidChangeFontToSize(arrayFontSizes[index])
    }
    
    func setSliderToIndex(index : Int, animated : Bool) {
        let adjustedValue : Float = (1 / (Float(arrayFontSizes.count)-1)) * Float(index)
        sliderFontSizes.setValue(adjustedValue, animated: animated)
    }
    
}