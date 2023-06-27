//
//  Scripting.swift
//  CodeFormerGUI
//
//  Created by Kelvin J on 6/1/23.
//

import Foundation

//@discardableResult // Add to suppress warnings when you don't want/need a result
//func safeShell(_ command: String) throws -> String {
//    let task = Process()
//    let pipe = Pipe()
//
//    task.launchPath = "/usr/bin/env"
//    task.standardOutput = pipe
//    task.standardError = pipe
//    task.arguments = ["-c", command]
////    task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
//    task.standardInput = nil
//
//    try task.run() //<--updated
//
//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let output = String(data: data, encoding: .utf8)!
//
//    return output
//}
@discardableResult
func safeShell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
//    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}
