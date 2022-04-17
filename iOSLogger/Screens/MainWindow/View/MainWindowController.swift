//
//  MainWindowController.swift
//  iOSLogger
//
//  Created by Aung Khant M. on 16/04/2022.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    var logContentViewController: LogContentViewController {
        contentViewController as! LogContentViewController
    }

    
    @IBOutlet weak var searchField: NSSearchField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        searchField.target = logContentViewController
        searchField.action = #selector(LogContentViewController.procSearchFieldInput(sender:))
    }
    @IBAction func onTapClearItem(_ sender: NSToolbarItem) {
        logContentViewController.clearTableView()
    }
}
