//
//  LogContentViewController.swift
//  iOSLogger
//
//  Created by Aung Khant M. on 12/04/2022.
//

import Cocoa

class LogContentViewController: NSViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: NSTableView!
    
    //MARK: - Properties
    
    lazy var viewModel = {
        LogContentViewModel()
    }()
    
    //MARK: UI States
    private var selectedRow : Int? = nil
    private var isAutoScrollEnabled = false
    
    //MARK: - VC LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        initViewModel()
    }
    
    override func viewDidDisappear() {
        // clean up the console helper object
        // is there any better way?
        viewModel.consoleHelper = nil
    }
    
    private func setupViews()
    {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.target = self
        self.tableView.action = #selector(self.onTableViewSingleClick)
    }
    
    private func initViewModel()
    {
        viewModel.logMessageList = [LogMessageModel]()
        
        // launch the console
        viewModel.launchConsole()
        
        // reload tableview closures
        viewModel.reloadTableViewWithReselect = { [weak self] in
            guard let strongSelf = self else { return }
            
            let selectedRow = strongSelf.tableView?.selectedRowIndexes
            
            DispatchQueue.main.async {
                strongSelf.tableView?.reloadData()
                
                if let x = selectedRow {
                    strongSelf.tableView?.selectRowIndexes(x, byExtendingSelection: false)
                }
                
                // scroll to added row
                if(strongSelf.isAutoScrollEnabled)
                {
                    let numberOfRows = strongSelf.tableView.numberOfRows
                    strongSelf.tableView.scrollRowToVisible(numberOfRows - 1)
                }
            }
        }
        
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Objective-C Functions
    
    @objc public func procSearchFieldInput (sender:NSSearchField) {
        print ("\(#function): \(sender.stringValue)")
        
        if !sender.stringValue.isEmpty{
            self.viewModel.textToSearch = sender.stringValue
            self.viewModel.searchAndDisplayItems(matching: sender.stringValue)
        } else {
            self.viewModel.stateOfSearch = .notRegularSearchYet
            self.viewModel.textToSearch = ""
            self.viewModel.searchedResultsList = nil
        }
    }
    
    @objc public func procAutoScrollToolbarItem(sender: NSToolbarItem)
    {
        if (isAutoScrollEnabled)
        {
            sender.toolbar?.selectedItemIdentifier = nil
            isAutoScrollEnabled = false
        } else {
            sender.toolbar?.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: "autoScroll")
            isAutoScrollEnabled = true
        }
    }
    
    @objc public func clearTableView() {
        self.viewModel.searchedResultsList = [LogMessageModel]()
        self.viewModel.logMessageList = [LogMessageModel]()
        self.tableView.reloadData()
    }
    
    @objc func pauseConsoleHelper() {
        if ( self.viewModel.consoleHelper != nil )
        {
            self.viewModel.consoleHelper.pause()
        }
    }
    
    @objc func resumeConsoleHelper()
    {
        if ( self.viewModel.consoleHelper != nil )
        {
            self.viewModel.consoleHelper.resume()
        }
    }
    
    @objc func onTableViewSingleClick()
    {
        // deselect the select row when user clicked
        if (selectedRow == tableView.clickedRow)
        {
            tableView.deselectRow(selectedRow ?? 0)
            selectedRow = nil
            return
        }
        selectedRow = tableView.clickedRow
    }
    
    @objc func actionCopyMenuItem(_ sender: NSMenuItem)
    {
        let clickedRow = self.tableView.clickedRow
        
        var description = "", time = "", processName = "", processType = "", parentProcess = "", pid = ""
        
        // time cell
        if let rowView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) {
            if let cellView = rowView.view(atColumn: 0) as? NSTableCellView {
                time = cellView.textField?.stringValue ?? "None"
            }
        }
        
        // process cell
        if let rowView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) {
            if let cellView = rowView.view(atColumn: 1) as? NSTableCellView {
                processName = cellView.textField?.stringValue ?? "None"
            }
        }
        
        // description cell
        if let rowView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) {
            if let cellView = rowView.view(atColumn: 2) as? NSTableCellView {
                description = cellView.textField?.stringValue ?? "None"
            }
        }
        
        // type cell
        if let rowView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) {
            if let cellView = rowView.view(atColumn: 3) as? NSTableCellView {
                processType = cellView.textField?.stringValue ?? "None"
            }
        }
        
        // parent cell
        
        if let rowView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) {
            if let cellView = rowView.view(atColumn: 4) as? NSTableCellView {
                parentProcess = cellView.textField?.stringValue ?? "None"
            }
        }
        
        // pid cell
        if let rowView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) {
            if let cellView = rowView.view(atColumn: 5) as? NSTableCellView {
                pid = cellView.textField?.stringValue ?? "None"
            }
        }
        
        let contentString = "\(time) \(processName)(\(parentProcess))[\(pid)] \(processType): \(description)"
        
        // copy to pasteboard
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(contentString, forType: .string)
    }

    deinit {
        
    }
}

//MARK: - NSTableView extensions
extension LogContentViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let logMessageList = self.viewModel.stateOfSearch == .regularSearch ? self.viewModel.searchedResultsList : self.viewModel.logMessageList
        return logMessageList?.count ?? 0
    }
    
    override func rightMouseDown(with event: NSEvent) {
        // Add popup menu
        // https://developer.apple.com/forums/thread/658198
        let copyMenu = copyContextMenu()
        NSMenu.popUpContextMenu(copyMenu, with: event, for: self.tableView) // returns a selected value
    }
    
    func copyContextMenu() -> NSMenu {
        let theMenu = NSMenu(title: "ContextMenu")
        theMenu.autoenablesItems = false
        
        let copyMenuItem = NSMenuItem(title: "Copy", action: #selector(actionCopyMenuItem(_:)), keyEquivalent: "")
        
        theMenu.addItem(copyMenuItem)
        return theMenu
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text = ""
        var cellIdentifier = ""
        
        let logMessageList = self.viewModel.stateOfSearch == .regularSearch ? self.viewModel.searchedResultsList : self.viewModel.logMessageList
        
        if (logMessageList?.count == 0 )
        {
            return nil
        }
        
        let model = logMessageList?[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = "\(model?.time ?? "N/A")"
            cellIdentifier = "timeCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = "\(model?.processName ?? "N/A")"
            cellIdentifier = "processCell"
        } else if tableColumn == tableView.tableColumns[2] {
            text = "\(model?.messageDetail ?? "N/A")"
            cellIdentifier = "descriptionCell"
        } else if tableColumn == tableView.tableColumns[3] {
            text = "\(model?.messageType ?? "N/A")"
            cellIdentifier = "typeCell"
        } else if tableColumn == tableView.tableColumns[4] {
            text = "\(model?.parentProcessName ?? "N/A")"
            cellIdentifier = "parentProcessCell"
        } else if tableColumn == tableView.tableColumns[5] {
            text = "\(model?.processPID ?? "N/A")"
            cellIdentifier = "processPIDCell"
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            
            // if stateOfSearch is in .regularSearch, then we would highlight the searching word
            if self.viewModel.stateOfSearch == .regularSearch {
                let attributedText = NSMutableAttributedString(string: text)
                let range = NSString(string: text).range(of: self.viewModel.textToSearch, options: .caseInsensitive)
                let highlightColor = NSColor.systemYellow
                let highlightedAttributes : [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: highlightColor]
                attributedText.addAttributes(highlightedAttributes, range: range)
                cell.textField?.attributedStringValue = attributedText
            }
            return cell
        }
        
        return nil
    }
}
