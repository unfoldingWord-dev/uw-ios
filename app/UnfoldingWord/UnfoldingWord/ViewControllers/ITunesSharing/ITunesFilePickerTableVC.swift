//
//  ITunesFilePickerTableVC.swift
//  UnfoldingWord
//
//  Created by David Solberg on 7/11/15.
//

import UIKit

@objc class ITunesFilePickerTableVC: UITableViewController {
    
    @objc let sharingReceiver : ITunesSharingReceiver
    @objc let cellId = NSStringFromClass(UFWTopLevelItemCell.self);
    @objc var chooseBlock : ITunesPickerChooseBlock?
    @objc let arrayFileNames : Array<String>
    
    @objc class func pickerInsideNavController(block : @escaping ITunesPickerChooseBlock) -> UINavigationController {
        let picker = ITunesFilePickerTableVC(style: UITableView.Style.plain, block: block)
        picker.navigationItem.title = "Choose a File to Import"
        picker.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: picker, action: #selector(cancel))
        
        let nav = UINavigationController(rootViewController: picker)
        nav.navigationBar.barTintColor = UIColor(red: 42.0/255.0, green: 34.0/255.0, blue: 26.0/255.0, alpha: 1.0)
        nav.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.white]
        return nav
    }
        
    @objc init(style: UITableView.Style, block : @escaping ITunesPickerChooseBlock){
        self.sharingReceiver = ITunesSharingReceiver()
        self.chooseBlock = nil
        self.arrayFileNames = self.sharingReceiver.filesToDisplayForImport()
        super.init(style: style)
        self.chooseBlock = block
    }
    
    @objc override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        self.sharingReceiver = ITunesSharingReceiver()
        self.arrayFileNames = self.sharingReceiver.filesToDisplayForImport()
        super.init(nibName: nibNameOrNil, bundle: nil)
    }

    @objc required init!(coder aDecoder: NSCoder) {
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
        self.edgesForExtendedLayout = UIRectEdge.all
    }
    
    @objc func loadCells() {
        let nib = UINib(nibName: self.cellId, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: self.cellId)
    }
    
    @objc func cancel() {
        if let chooseBlock = self.chooseBlock {
            chooseBlock(true, nil)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.arrayFileNames.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UFWTopLevelItemCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! UFWTopLevelItemCell
        if self.arrayFileNames.count > 0 {
            let filepath = self.arrayFileNames[indexPath.row]
            let filename = (filepath as NSString).lastPathComponent
            cell.labelName.text = filename as String
        }
        else {
            cell.labelName.text = "No new files in the iTunes folder"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let chooseBlock = self.chooseBlock {
            if self.arrayFileNames.count == 0 {
                chooseBlock(true, nil)
            }
            else {
                let filepath = self.arrayFileNames[indexPath.row]
                chooseBlock(false, filepath as String)
            }
        }
    }
    
}
