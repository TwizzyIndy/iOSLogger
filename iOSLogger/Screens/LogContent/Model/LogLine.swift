//
//  LogLine.swift
//  iOSLogger
//
//  Created by Aung Khant M. on 13/04/2022.
//

import Foundation

struct LogLine {
    
    var messageModel: LogMessageModel? = nil
    
    init(logMessage: String) {
        let pattern = #"(...) (\d\d) (.*?) (.*?) (.*?) (.*?)\: (.*?)\n"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            let nsrange = NSRange(logMessage.startIndex..<logMessage.endIndex, in: logMessage)
            
            regex.enumerateMatches(in: logMessage, options: [], range: nsrange) { (match, _, stop) in
                guard let match = match else {
                    return
                }
                
                if match.numberOfRanges == 8,
                   let firstRange = Range(match.range(at: 1), in: logMessage),
                   let secondRange = Range(match.range(at: 2), in: logMessage),
                   let thirdRange = Range(match.range(at: 3), in: logMessage),
                   let fourthRange = Range(match.range(at: 4), in: logMessage),
                   let fifthRange = Range(match.range(at: 5), in: logMessage),
                   let sixthRange = Range(match.range(at: 6), in: logMessage),
                   let seventhRange = Range(match.range(at: 7), in: logMessage)
                {
                    let monthStr = String(logMessage[firstRange])
                    let dayStr = String(logMessage[secondRange])
                    let timeStr = String(logMessage[thirdRange])
                    let deviceNameStr = String(logMessage[fourthRange])
                    let processNameStr = String(logMessage[fifthRange]) // TODO: parse PID. e.g: bluetoothd(IOKit)[85]
                    let messageTypeStr = String(logMessage[sixthRange])
                    let messageDetailStr = String(logMessage[seventhRange])
                    
                    
                    let model = LogMessageModel(month: monthStr, day: dayStr, time: timeStr, deviceName: deviceNameStr, processName: processNameStr, messageType: messageTypeStr, messageDetail: messageDetailStr)
                    
                    self.messageModel = model
                    
                }

            }
            
        } catch {
            print("error in regex")
            return
        }
        

    }
    
}
