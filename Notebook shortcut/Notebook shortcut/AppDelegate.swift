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
    
    let task = Process()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        if let button = statusItem.button {
            button.image = NSImage(named: "StatusIcon")
            button.action = #selector(mouseClickHandler)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        menu.delegate = self

        DispatchQueue.global(qos: .utility).async{
            self.StartNotebook(self.task)
        }
        
    }
    
    @objc func mouseClickHandler() {
        if let event = NSApp.currentEvent {
            switch event.type {
                case .rightMouseUp:
                    // 使用警告窗口示意左键单击
//                    let alert = NSAlert()
//                    alert.messageText = "鼠标事件"
//                    alert.informativeText = "右键单击"
//                    alert.addButton(withTitle: "关闭")
//                    alert.window.titlebarAppearsTransparent = true
//                    alert.runModal()
//                    关闭程序
                    NSApplication.shared.terminate(self)
                default:
                    statusItem.menu = menu
                    statusItem.button?.performClick(nil)
            }
        }
    }

    @IBAction func OpenNotebook(_ sender: NSMenuItem) {
//        StartNotebook()
        //open safair
        let url = URL(string: "http://localhost:8888/tree")!
        if NSWorkspace.shared.open(url) {
            NSLog("log: %@", "default browser was successfully opened")

        }
        
    }
    
    func StartNotebook(_ task: Process) {
//    func StartNotebook() {
//        let task = Process()
        
//        var environment =  ProcessInfo.processInfo.environment
//        environment["PATH"] = "/Users/colin"
//        task.environment = environment
        
        task.launchPath = "/usr/bin/env/"
//        task.arguments = ["which", "pip"]
//        task.arguments = ["pwd"]
        task.arguments = ["/Users/colin/Library/Python/2.7/bin/jupyter-notebook"]
        task.currentDirectoryPath = "/Users/colin"
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: String.Encoding.utf8)!
        NSLog("log: %@", output)
        
        let errdata = errpipe.fileHandleForReading.availableData
        let errString = String(data: errdata, encoding: String.Encoding.utf8) ?? ""
        NSLog("错误: %@", errString)
        
        
        pipe.fileHandleForReading.closeFile()
        
        print("DEBUG 24: run_shell finish.")
        print(Int(task.terminationStatus))
        
//        task.waitUntilExit()


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


struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
