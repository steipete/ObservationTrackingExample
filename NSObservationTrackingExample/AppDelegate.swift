import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var sharedDataModel: SharedDataModel?
    private var appKitWindowController: AppKitWindowController?
    
    func openAppKitWindow() {
        guard let dataModel = sharedDataModel else {
            print("Error: No shared data model available")
            return
        }
        
        if appKitWindowController == nil {
            appKitWindowController = AppKitWindowController(dataModel: dataModel)
        }
        
        appKitWindowController?.showWindow(nil)
        appKitWindowController?.window?.makeKeyAndOrderFront(nil)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application did finish launching")
        // The AppKit window will be opened from ContentView.onAppear
    }
}