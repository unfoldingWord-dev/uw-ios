//
//  ITunesFilePickerTableVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/11/15.
//

import UIKit

class ITunesFilePickerTableVC: UITableViewController {
    
    let sharingReceiver : ITunesSharingReceiver
    let cellId = NSStringFromClass(UFWTopLevelItemCell);
    var chooseBlock : ITunesPickerChooseBlock?
    let arrayFileNames : Array<NSString>
    
    class func pickerInsideNavController(block : ITunesPickerChooseBlock) -> UINavigationController {
        let picker = ITunesFilePickerTableVC(style: UITableViewStyle.Plain, block: block)
        picker.navigationItem.title = "Choose a File to Import"
        picker.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: picker, action: "cancel")
        
        let nav = UINavigationController(rootViewController: picker)
        nav.navigationBar.barTintColor = UIColor(red: 42.0/255.0, green: 34.0/255.0, blue: 26.0/255.0, alpha: 1.0)
        nav.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor()]
        return nav
    }
        
    init(style: UITableViewStyle, block : ITunesPickerChooseBlock){
        self.sharingReceiver = ITunesSharingReceiver()
        self.chooseBlock = nil
        self.arrayFileNames = self.sharingReceiver.filesToDisplayForImport()
        super.init(style: style)
        self.chooseBlock = block
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.sharingReceiver = ITunesSharingReceiver()
        self.arrayFileNames = self.sharingReceiver.filesToDisplayForImport()
        super.init(nibName: nibNameOrNil, bundle: nil)
    }

    required init!(coder aDecoder: NSCoder) {
        assertionFailure("Don't use this!")
        self.sharingReceiver = ITunesSharingReceiver()
        self.arrayFileNames = self.sharingReceiver.filesToDisplayForImport()
        self.chooseBlock = { (canceled : Bool, chosenPath : String?) in return}
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCells()
        self.automaticallyAdjustsScrollViewInsets = true
        self.edgesForExtendedLayout = UIRectEdge.All
    }
    
    func loadCells() {
        let nib = UINib(nibName: self.cellId, bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: self.cellId)
    }
    
    func cancel() {
        if let chooseBlock = self.chooseBlock {
            chooseBlock(canceled: true, chosenPath: nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.arrayFileNames.count, 1)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell : UFWTopLevelItemCell = tableView.dequeueReusableCellWithIdentifier(self.cellId, forIndexPath: indexPath) as! UFWTopLevelItemCell
        if self.arrayFileNames.count > 0 {
            let filepath = self.arrayFileNames[indexPath.row]
            let filename = filepath.lastPathComponent
            cell.labelName.text = filename as String
        }
        else {
            cell.labelName.text = "No new files in the iTunes folder"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let chooseBlock = self.chooseBlock {
            
            if self.arrayFileNames.count == 0 {
                chooseBlock(canceled: true, chosenPath: nil)
            }
            else {
                let filepath = self.arrayFileNames[indexPath.row]
                chooseBlock(canceled: false, chosenPath: filepath as String)
            }
        }
    }
    
}
