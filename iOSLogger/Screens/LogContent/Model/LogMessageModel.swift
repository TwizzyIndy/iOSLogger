//
//  LogMessageModel.swift
//  iOSLogger
//
//  Created by Aung Khant M. on 13/04/2022.
//

import Foundation

struct LogMessageModel {
    let month: String
    let day: String
    let time: String
    let deviceName: String
    let processName: String
    let messageType: String
    let messageDetail: String
    let parentProcessName: String
    let processPID: String
}
