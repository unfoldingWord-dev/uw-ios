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

class ChooseMediaToShareTableVC: UITableViewController, LanguageChooserCellDelegate {
    
    var completion : VersionSharingCompletion! = nil
    var arrayTopSharing : [[LanguageSharingInfo]] = UWTopContainer.sortedLanguagedSharingInfoForDownloadedItems()
    
    let cellId = NSStringFromClass(LanguageShareChooserTableCell)
    
    static func chooserInNavControllerWithCompletion(completion : VersionSharingCompletion) -> UINavigationController
    {
        let vc = ChooseMediaToShareTableVC()
        vc.completion = completion
        return UINavigationController(rootViewController: vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cell = UINib.init(nibName: cellId.textAfterLastPeriod(), bundle: nil)
        self.tableView.registerNib(cell, forCellReuseIdentifier: cellId)
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.separatorStyle = .None
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }
    
    func userTappedCell(cell: LanguageShareChooserTableCell) {
        guard let indexPath = tableView.indexPathForCell(cell) else { assertionFailure("Tapped nonexistent cell?!?"); return }
        let sharingInfo = arrayTopSharing[indexPath.section][indexPath.row]
        sharingInfo.isExpanded = !sharingInfo.isExpanded
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - TableView Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arrayTopSharing.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sharingInfoArray: [LanguageSharingInfo] = arrayTopSharing[section]
        return sharingInfoArray.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sharingInfoArray: [LanguageSharingInfo] = arrayTopSharing[section]
        if sharingInfoArray.count > 0 {
            let langSharingInfo = sharingInfoArray[0]
            return langSharingInfo.language.topContainer.title
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! LanguageShareChooserTableCell
        cell.sharingInfo = arrayTopSharing[indexPath.section][indexPath.row]
        cell.delegate = self
        return cell
    }


}
