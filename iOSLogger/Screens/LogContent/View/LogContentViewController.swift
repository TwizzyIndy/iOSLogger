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
    var logMessageList : [LogMessageModel]?
    var consoleHelper : LogConsoleHelper!
    
    //MARK: - VC LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()

        consoleHelper = LogConsoleHelper(onStdOut: { [unowned tableView] text in
            
            let line = LogLine(logMessage: text)
            if let msg = line.messageModel {
                self.logMessageList?.append(msg)
                
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
                
                self.logMessageList?.append(msg)
                
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

    deinit {
        
    }
}

//MARK: - NSTableView extensions
extension LogContentViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        self.logMessageList?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text = ""
        var cellIdentifier = ""
        
        guard let model = self.logMessageList?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = "\(model.time)"
            cellIdentifier = "timeCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = "\(model.processName)"
            cellIdentifier = "processCell"
        } else if tableColumn == tableView.tableColumns[2] {
            text = "\(model.messageDetail)"
            cellIdentifier = "descriptionCell"
        } else if tableColumn == tableView.tableColumns[3] {
            text = "\(model.messageType)"
            cellIdentifier = "typeCell"
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            
            return cell
        }
        
        return nil
    }
}
