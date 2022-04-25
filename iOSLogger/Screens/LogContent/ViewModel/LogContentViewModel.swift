//
//  LogContentViewModel.swift
//  iOSLogger
//
//  Created by Aung Khant M. on 19/04/2022.
//

import Cocoa

class LogContentViewModel: NSObject {
    
    var reloadTableView: (() -> Void)?
    var reloadTableViewWithReselect: (() -> Void)?
    
    var logMessageList = [LogMessageModel]()
    
    var searchedResultsList : [LogMessageModel]?
    
    var consoleHelper : LogConsoleHelper!
    
    enum SearchState {
        case regularSearch
        case notRegularSearchYet
        case noResults
        case discoverySearch
    }
    
    var stateOfSearch: SearchState = .discoverySearch
    var textToSearch = ""
    
    
    /// Launch the log console and capture output
    func launchConsole()
    {
        consoleHelper = LogConsoleHelper(onStdOut: { [weak self] text in
            
            guard let strongSelf = self else { return }
            
            let line = LogLine(logMessage: text)
            if let msg = line.messageModel {
                
                // if searching, just add contained search result into table
                if strongSelf.stateOfSearch == .regularSearch {
                    if msg.messageDetail.contains(strongSelf.textToSearch) || msg.processName.contains(strongSelf.textToSearch) {
                        strongSelf.searchedResultsList?.append(msg)
                    }
                }
                
                strongSelf.logMessageList.append(msg)
                
                // we should have to re-select the row
                strongSelf.reloadTableViewWithReselect?()
            }
        }, onStdErr: { [weak self] text in
            
            guard let strongSelf = self else { return }
            
            let line = LogLine(logMessage: text)
            if let msg = line.messageModel {
                
                // if searching, just add contained search result into table
                if strongSelf.stateOfSearch == .regularSearch {
                    if msg.messageDetail.contains(strongSelf.textToSearch) || msg.processName.contains(strongSelf.textToSearch) {
                        strongSelf.searchedResultsList?.append(msg)
                    }
                }
                
                strongSelf.logMessageList.append(msg)
                
                // we should have to re-select the row
                strongSelf.reloadTableViewWithReselect?()
            }
        })
    }
    
    func searchAndDisplayItems(matching query: String)
    {
        let result = self.logMessageList.filter {
            $0.messageDetail.contains(query) || $0.processName.contains(query)
        }
        
        self.stateOfSearch = result.count > 0 ? .regularSearch : .noResults
        
        if self.stateOfSearch == .regularSearch {
            self.searchedResultsList = result
            self.reloadTableView?()
        }
    }

}
