//
//  MediaTypeView.swift
//  UnfoldingWord
//
//  Created by David Solberg on 11/24/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import UIKit

class MediaTypeView: UIView {

    @IBOutlet weak var imageViewType: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonCheckingLevel: UIButton!
    @IBOutlet weak var buttonDownload: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViewVerify: UIImageView!
    @IBOutlet weak var buttonBackground: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    var downloadButtonBlock : ButtonPressBlock? = nil
    var backgroundButtonBlock : ButtonPressBlock? = nil
    var checkingLevelButtonBlock : ButtonPressBlock? = nil
    var deleteButtonBlock : ButtonPressBlock? = nil
    
    func hideRightEdgeViewsExcept(view : UIView) {
        if (view === activityIndicator) {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        buttonDownload.hidden = buttonDownload === view ? false : true
        imageViewVerify.hidden = imageViewVerify === view ? false : true
        buttonDelete.hidden = buttonDelete === view ? false : true
    }
    
    // Custom getter and setter because of some issue with the Swift headers. Ideally this would just be an plain var called type.
    private var internalType : MediaType = .Text
    
    func setType(type : MediaType) {
        internalType = type
    }
    
    func getType() -> MediaType {
        return internalType
    }
    
    @IBAction func userPressedBackgroundButton(sender: UIButton) {
        fire(backgroundButtonBlock)
    }
    
    @IBAction func userPressedDownloadButton(button : UIButton) {
        fire(downloadButtonBlock)
    }
    
    @IBAction func userPressedCheckingLevelButton(sender: UIButton) {
        fire(checkingLevelButtonBlock)
    }
    
    @IBAction func userPressedDeleteButton(sender: UIButton) {
        fire(deleteButtonBlock)
    }
    
    private func fire(block : ButtonPressBlock?) {
        guard let block = block else {
            assertionFailure("No outlet for button!")
            return }
        block()
    }
    
}
