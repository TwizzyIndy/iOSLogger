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
        let pattern = #"(...)\s{1,}(\d{1,}) (.*?) (.*?) (.*?) (.*?)\: (.*?)\n"#
        
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
                    let processNameStr = String(logMessage[fifthRange]) // parse PID. e.g: bluetoothd(IOKit)[85]
                    
                    // the exact process name
                    let exactProcessName = getExactProcessNameWithRegex(processNameStr)
                    
                    // parse parent process name
                    let parentProcessName = self.getParentProcessNameWithRegex(processNameStr)
                    
                    // parse process PID
                    let processPID = self.getProcessPIDWithRegex(processNameStr)
                    
                    let messageTypeStr = String(logMessage[sixthRange])
                    let messageDetailStr = String(logMessage[seventhRange])
                    
                    
                    let model = LogMessageModel(month: monthStr, day: dayStr, time: timeStr, deviceName: deviceNameStr, processName: exactProcessName ?? "N/A", messageType: messageTypeStr, messageDetail: messageDetailStr, parentProcessName: parentProcessName ?? "N/A", processPID: processPID ?? "N/A")
                    
                    self.messageModel = model
                    
                }

            }
            
        } catch {
            print("error in regex")
            return
        }
        

    }
    
    private func getExactProcessNameWithRegex(_ processName: String) -> String?
    {
        var result : String? = nil
        
        // remove string between the brackets
        let newProcessName = processName.replacingOccurrences(of: #"\[.*?\]"#, with: "", options: .regularExpression)
        result = newProcessName
        
        let pattern = #"(.*?)\("#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsrange = NSRange(newProcessName.startIndex..<newProcessName.endIndex, in: newProcessName)
            
            regex.enumerateMatches(in: newProcessName, options: [], range: nsrange) { (match, _, stop) in
                guard let match = match else {
                    return
                }
                
                if match.numberOfRanges == 2,
                   let firstCaptureRange = Range(match.range(at: 1), in: newProcessName)
                {
                    let capturedValue = String(newProcessName[firstCaptureRange])
                    result = capturedValue
                }

            }

        } catch {
            print("error in regex")
        }
        return result
    }
    
    private func getParentProcessNameWithRegex(_ processName: String) -> String?
    {
        var result : String? = nil
        let pattern = #"\((.*?)\)"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsrange = NSRange(processName.startIndex..<processName.endIndex, in: processName)
            
            regex.enumerateMatches(in: processName, options: [], range: nsrange) { (match, _, stop) in
                guard let match = match else {
                    return
                }
                
                if match.numberOfRanges == 2,
                   let firstCaptureRange = Range(match.range(at: 1), in: processName)
                {
                    let capturedValue = String(processName[firstCaptureRange])
                    result = capturedValue
                }

            }

        } catch {
            print("error in regex")
        }
        return result
    }
    
    private func getProcessPIDWithRegex(_ processName: String) -> String?
    {
        var result : String? = nil
        let pattern = #"\[(.*?)\]"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsrange = NSRange(processName.startIndex..<processName.endIndex, in: processName)
            
            regex.enumerateMatches(in: processName, options: [], range: nsrange) { (match, _, stop) in
                guard let match = match else {
                    return
                }
                
                if match.numberOfRanges == 2,
                   let firstCaptureRange = Range(match.range(at: 1), in: processName)
                {
                    let capturedValue = String(processName[firstCaptureRange])
                    result = capturedValue
                }

            }
        } catch {
            print("error in regex")
        }
        
        return result
    }
    
}
