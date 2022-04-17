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
    var logMessageList : [LogMessageModel] = []
    
    var searchedResultsList : [LogMessageModel]?
    
    var consoleHelper : LogConsoleHelper!
    
    //MARK: UI States
    enum SearchState {
        case regularSearch
        case notRegularSearchYet
        case noResults
        case discoverySearch
    }
    
    private var stateOfSearch: SearchState = .discoverySearch
    private var textToSearch = ""
    
    //MARK: - VC LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()

        consoleHelper = LogConsoleHelper(onStdOut: { [unowned tableView] text in
            
            let line = LogLine(logMessage: text)
            if let msg = line.messageModel {
                
                // if searching, just add contained search result into table
                if self.stateOfSearch == .regularSearch {
                    if msg.messageDetail.contains(self.textToSearch) {
                        self.searchedResultsList?.append(msg)
                    }
                }
                
                self.logMessageList.append(msg)
                
                // we should have to re-select the row
                let selectedRow = tableView?.selectedRowIndexes
                
                DispatchQueue.main.async {
                    tableView?.reloadData()
                    
                    if let x = selectedRow {
                        tableView?.selectRowIndexes(x, byExtendingSelection: false)
                    }
                }
            }
        }, onStdErr: { [unowned tableView] text in
            
            let line = LogLine(logMessage: text)
            if let msg = line.messageModel {
                
                // if searching, just add contained search result into table
                if self.stateOfSearch == .regularSearch {
                    if msg.messageDetail.contains(self.textToSearch) {
                        self.searchedResultsList?.append(msg)
                    }
                }
                
                self.logMessageList.append(msg)
                
                // we should have to re-select the row
                let selectedRow = tableView?.selectedRowIndexes
                
                DispatchQueue.main.async {
                    tableView?.reloadData()
                    
                    if let x = selectedRow {
                        tableView?.selectRowIndexes(x, byExtendingSelection: false)
                    }
                }
            }
        })
        
    }
    
    override func viewDidDisappear() {
        // clean up the console helper object
        // is there any better way?
        consoleHelper = nil
    }
    
    private func setupViews()
    {
        self.logMessageList = [LogMessageModel]()
        self.tableView.dataSource = self
        self.tableView.delegate = self        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func searchAndDisplayItems(matching query: String)
    {
        let result = self.logMessageList.filter {
            $0.messageDetail.contains(query) || $0.processName.contains(query)
        }
        
        self.stateOfSearch = result.count > 0 ? .regularSearch : .noResults
        
        if self.stateOfSearch == .regularSearch {
            self.searchedResultsList = result
            self.tableView.reloadData()
        }
        
    }
    
    @objc public func procSearchFieldInput (sender:NSSearchField) {
        print ("\(#function): \(sender.stringValue)")
        
        if !sender.stringValue.isEmpty{
            self.textToSearch = sender.stringValue
            searchAndDisplayItems(matching: sender.stringValue)
        } else {
            self.stateOfSearch = .notRegularSearchYet
            self.textToSearch = ""
            self.searchedResultsList = nil
        }
    }

    deinit {
        
    }
}

//MARK: - NSTableView extensions
extension LogContentViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let logMessageList = self.stateOfSearch == .regularSearch ? self.searchedResultsList : self.logMessageList

        return logMessageList?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text = ""
        var cellIdentifier = ""
        
        let logMessageList = self.stateOfSearch == .regularSearch ? self.searchedResultsList : self.logMessageList
        
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
            if self.stateOfSearch == .regularSearch {
                let attributedText = NSMutableAttributedString(string: text)
                let range = NSString(string: text).range(of: self.textToSearch, options: .caseInsensitive)
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
