//
//  LogConsoleHelper.swift
//  iOSLogger
//
//  Created by Aung Khant M. on 12/04/2022.
//

import Foundation

// this class is based on
// https://github.com/objcio/S01E148-string-handling/blob/master/Sources/MarkdownPlayground/App.swift

final class LogConsoleHelper
{
    private let process = Process()
    private let stdErr = Pipe()
    private let stdOut = Pipe()
    
    private var stdOutToken: Any?
    private var stdErrToken: Any?
    
    init(onStdOut: @escaping (String) -> (), onStdErr: @escaping (String) -> ()) {
        
        // get TMobileDeviceConsole path
        guard let resourcePath = Bundle.main.resourcePath else { return }
        
        let deviceConsolePath = "\(resourcePath)/TMobileDeviceConsole"
        process.executableURL = URL(fileURLWithPath: deviceConsolePath)
        
        // setup output
        process.standardOutput = stdOut.fileHandleForWriting
        process.standardError = stdErr.fileHandleForWriting
        
        // standard output
        var stdOutBuffer = REPLBuffer()
        stdOutToken = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: stdOut.fileHandleForReading, queue: nil, using: {
            [unowned self] note in
            
            if let string = stdOutBuffer.append(self.stdOut.fileHandleForReading.availableData ) {
                onStdOut(string)
            }
            self.stdOut.fileHandleForReading.waitForDataInBackgroundAndNotify()
        })
        
        // standard error
        var stdErrBuffer = REPLBuffer()
        stdErrToken = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable , object:stdErr.fileHandleForReading, queue:nil, using: {
            [unowned self] note in
            if let string = stdErrBuffer.append(self.stdErr.fileHandleForReading.availableData) {
                onStdErr(string)
            }
            self.stdErr.fileHandleForReading.waitForDataInBackgroundAndNotify()
        })
        
        do {
            try process.run()
        } catch {
            print("launch error")
            return
        }
        
        stdOut.fileHandleForReading.waitForDataInBackgroundAndNotify()
        stdErr.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    func pause()
    {
        if self.process.isRunning {
            self.process.suspend()
        }
    }
    
    func resume()
    {
        if self.process.isRunning {
            self.process.resume()
        }
    }
    
    deinit {
        self.process.terminate()
        
        if let t = stdOutToken { NotificationCenter.default.removeObserver(t) }
        if let e = stdErrToken { NotificationCenter.default.removeObserver(e) }
    }
}

struct REPLBuffer {
    private var buffer = Data()
    
    mutating func append(_ data: Data) -> String? {
        buffer.append(data)
        if let string = String(data: buffer, encoding: .utf8), string.last?.isNewline == true {
            buffer.removeAll()
            return string
        }
        return nil
    }
}
