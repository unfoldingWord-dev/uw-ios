//
//  ChooseMediaToShareTableVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 12/10/15.
//  Copyright © 2015 Acts Media Inc. All rights reserved.
//

import Foundation
import UIKit

typealias VersionSharingCompletion = (isCanceled: Bool, versionSharingInfoArray: [VersionSharingInfo])


class ChooseMediaToShareTableVC: UITableViewController {
    
    var completion : VersionSharingCompletion? = nil
    var topContainers = UWTopContainer.sortedContainers()
    var expandedLanguages = [UWLanguage]()
    
    static func chooserInNavControllerWithCompletion(completion : VersionSharingCompletion) -> UINavigationController
    {
        let vc = ChooseMediaToShareTableVC()
        vc.completion = completion
        return UINavigationController(rootViewController: vc)
    }
    
    // MARK: - TableView Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return topContainers.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let top = topContainers[section]
        return top.sortedLanguages.count
    }
    
    func setLanguage(language : UWLanguage, toExpanded expanded: Bool)
    {
        let existingIndex : Int? = expandedLanguages.indexOf(language)
        if let existingIndex = existingIndex where expanded == false {
            expandedLanguages.removeAtIndex(existingIndex)
            return
        }
        else if let _ = existingIndex where expanded == true {
            return
        }
        else if expanded == true {
            expandedLanguages.append(language)
        }
    }
    
    func isExpandedLanguage(language : UWLanguage) -> Bool {
        return expandedLanguages.indexOf(language) != nil
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        let cell : UFWTopLevelItemCell = tableView.dequeueReusableCellWithIdentifier(self.cellId, forIndexPath: indexPath) as! UFWTopLevelItemCell
//        if self.arrayFileNames.count > 0 {
//            let filepath = self.arrayFileNames[indexPath.row]
//            let filename = filepath.lastPathComponent
//            cell.labelName.text = filename as String
//        }
//        else {
//            cell.labelName.text = "No new files in the iTunes folder"
//        }
//        return cell
//    }
//    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if let chooseBlock = self.chooseBlock {
//            
//            if self.arrayFileNames.count == 0 {
//                chooseBlock(canceled: true, chosenPath: nil)
//            }
//            else {
//                let filepath = self.arrayFileNames[indexPath.row]
//                chooseBlock(canceled: false, chosenPath: filepath as String)
//            }
//        }
//    }

}
