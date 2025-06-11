//
//  NSObservationTrackingExampleApp.swift
//  NSObservationTrackingExample
//
//  Created by Peter Steinberger on 10.06.25.
//

import SwiftUI
import AppKit
import Combine

@main
struct NSObservationTrackingExampleApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .onAppear {
                    // Open AppKit window as soon as SwiftUI window appears
                    appState.openAppKitWindow()
                }
        }
    }
}

// Shared app state that manages both windows
@MainActor
final class AppState: ObservableObject {
    let dataModel = SharedDataModel()
    private var appKitWindowController: AppKitWindowController?
    
    func openAppKitWindow() {
        if appKitWindowController == nil {
            appKitWindowController = AppKitWindowController(dataModel: dataModel)
        }
        appKitWindowController?.showWindow(nil)
        appKitWindowController?.window?.makeKeyAndOrderFront(nil)
    }
}