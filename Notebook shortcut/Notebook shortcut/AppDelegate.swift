//
//  AppDelegate.swift
//  Jupyter notebook
//
//  Created by Colin on 2020/11/18.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    @IBOutlet weak var menu: NSMenu!
    // cmd for starting notebook
    let task = Process()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if !UserDefaults.standard.bool(forKey: "isFirstLaunch") {
            
//            NSLog("is first launch")
            
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            //get user's home directory. eg. "HOME": "/Users/colin"
//            let environment =  ProcessInfo.processInfo.environment
            UserDefaults.standard.set(ProcessInfo.processInfo.environment["HOME"], forKey: "HOME")
            UserDefaults.standard.set(["/Users/colin/Library/Python/2.7/bin/jupyter-notebook"], forKey: "NotebookPath")
        }
//        else{
//            NSLog("not first launch")
//            print(UserDefaults.standard.string(forKey: "HOME") as Any)
//            print(UserDefaults.standard.stringArray(forKey: "NotebookPath") as Any)
//        }
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusIcon")
            button.action = #selector(mouseClickHandler)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        menu.delegate = self

        // run notebook in thread
//        StartNotebook(self.task)
        DispatchQueue.global(qos: .utility).async{
            
            self.StartNotebook(self.task)
//            NSLog("nb ends")
            // notebook thread ends, end this app
            DispatchQueue.main.async {
                NSApplication.shared.terminate(self)
            }
        }

        
    }
    
    @objc func mouseClickHandler() {
        if let event = NSApp.currentEvent {
            switch event.type {
                case .rightMouseUp:
                    NSApplication.shared.terminate(self)
                default:
                    statusItem.menu = menu
                    statusItem.button?.performClick(nil)
            }
        }
    }

    @IBAction func OpenNotebook(_ sender: NSMenuItem) {
        //open safair
        let url = URL(string: "http://localhost:8888/tree")!
        NSWorkspace.shared.open(url)
//        if NSWorkspace.shared.open(url) {
//            NSLog("log: %@", "default browser was successfully opened")
//        }
    }
    
    func StartNotebook(_ task: Process) {
//    func StartNotebook() {
//        let task = Process()
        
//        var environment =  ProcessInfo.processInfo.environment
//        environment["PATH"] = "/Users/colin"
//        task.environment = environment
        
        task.launchPath = "/usr/bin/env/"

//        task.arguments = ["/Users/colin/Library/Python/2.7/bin/jupyter-notebook"]
//        task.currentDirectoryPath = "/Users/colin"
        
        task.arguments = UserDefaults.standard.stringArray(forKey: "NotebookPath")
        task.currentDirectoryPath = UserDefaults.standard.string(forKey: "HOME") ?? "/Users"
        
//        let infoPipe = Pipe()
//        task.standardOutput = infoPipe
//        let errpipe = Pipe()
//        task.standardError = errpipe

        task.launch()

//        let data = infoPipe.fileHandleForReading.readDataToEndOfFile()
//        let output: String = String(data: data, encoding: String.Encoding.utf8)!
//        NSLog("log: %@", output)
//
//        let errdata = errpipe.fileHandleForReading.availableData
//        let errString = String(data: errdata, encoding: String.Encoding.utf8) ?? ""
//        NSLog("错误: %@", errString)
        
        
//        infoPipe.fileHandleForReading.closeFile()
//        errpipe.fileHandleForReading.closeFile()

//        NSLog("DEBUG 24: run_shell finish.")
//        print(Int(task.terminationStatus))

        task.waitUntilExit()
    }
    
    @IBAction func quitApp(_ sender: NSMenuItem) {
        task.terminate()
        NSApplication.shared.terminate(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        task.terminate()
    }


}

extension AppDelegate: NSMenuDelegate {
    // 为了保证按钮的单击事件设置有效，menu要去除
    func menuDidClose(_ menu: NSMenu) {
        self.statusItem.menu = nil
    }
}
