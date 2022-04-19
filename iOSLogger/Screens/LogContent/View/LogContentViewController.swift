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
    private var selectedRow = 1
    
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
            let selectedRow = self?.tableView?.selectedRowIndexes
            
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
                
                if let x = selectedRow {
                    self?.tableView?.selectRowIndexes(x, byExtendingSelection: false)
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
            tableView.deselectRow(selectedRow)
            return
        }
        selectedRow = tableView.clickedRow
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
