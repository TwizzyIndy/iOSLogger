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
    
    // MARK: - UI States
    private var isPaused = false

    // MARK: - IBOutlets
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var pauseToolbarItem: NSToolbarItem!
    @IBOutlet weak var autoScrollToolbarItem: NSToolbarItem!
    
    // MARK: - Life cycles
    override func windowDidLoad() {
        super.windowDidLoad()
        
        searchField.target = logContentViewController
        searchField.action = #selector(LogContentViewController.procSearchFieldInput(sender:))
        
        // for autoscroll toolbar item
        autoScrollToolbarItem.target = logContentViewController
        autoScrollToolbarItem.action = #selector(logContentViewController.procAutoScrollToolbarItem)
        
        // setup views
        setupViews()
    }
    
    private func setupViews()
    {
        if #available(macOS 11.0, *) {
            pauseToolbarItem.image = NSImage(systemSymbolName: "pause.circle", accessibilityDescription: nil)
        } else {
            pauseToolbarItem.image = NSImage(named: "pause.circle")
        }
    }
    
    // MARK: - IB Actions
    @IBAction func onTapClearItem(_ sender: NSToolbarItem) {
        logContentViewController.clearTableView()
    }
    
    @IBAction func onTapPauseItem(_ sender: NSToolbarItem) {
        if (!self.isPaused)
        {
            logContentViewController.pauseConsoleHelper()
            
            isPaused = true
            
            if #available(macOS 11.0, *) {
                pauseToolbarItem.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: nil)
            } else {
                pauseToolbarItem.image = NSImage(named: "play.circle" )
            }
            
            pauseToolbarItem.label = "Resume"
        } else {
            logContentViewController.resumeConsoleHelper()
            isPaused = false
            
            if #available(macOS 11.0, *) {
                pauseToolbarItem.image = NSImage(systemSymbolName: "pause.circle", accessibilityDescription: nil)
            } else {
                pauseToolbarItem.image = NSImage(named: "pause.circle" )
            }
            
            pauseToolbarItem.label = "Pause"
        }
    }
}
