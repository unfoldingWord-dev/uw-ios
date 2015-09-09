//
//  USFMChapterVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 9/9/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

import Foundation

class USFMChapterVC : UIViewController, UITextViewDelegate {
    
    var tocMain : UWTOC?
    var arrayMainChapters: [USFMChapter]?
    var tocSide : UWTOC?
    var arraySideChapters: [USFMChapter]?
    var chapterNumber : Int?
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewSideDiglot: UIView!
    
    @IBOutlet weak var textViewMain: UITextView!
    @IBOutlet weak var textViewSideDiglot: UITextView!
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func loadContentForTextView(textView : UITextView, toc : UWTOC?, chapterNumber : Int) {
        
        if let toc = toc, chapters = matchingChaptersForTOC(toc) where chapterNumber < chapters.count && chapterNumber >= 0 {
            textView.textAlignment = LanguageInfoController.textAlignmentForLanguageCode(toc.version.language.lc)
            let chapter : USFMChapter = chapters[chapterNumber]
            textView.attributedText = chapter.attributedString;
        }
        else if toc == nil {
            textView.text = "Nothing selected."
        }
    }
    
    private func matchingChaptersForTOC(toc : UWTOC) -> [USFMChapter]? {
        if toc.isEqual(tocMain) {
            return arrayMainChapters
        }
        else if toc.isEqual(tocSide) {
            return arraySideChapters
        }
        else {
            assertionFailure("Specified a toc that doesn't exist: \(toc)")
            return nil
        }
    }
    
}
