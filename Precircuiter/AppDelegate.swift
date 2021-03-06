//
//  AppDelegate.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 8/25/14.
//  Copyright © 2014 Harry Shamansky. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var startScreenWindowController: NSWindowController?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        // Create an instance of the sub-classed document controller.
        // This will be set as the shared document controller, according to the spec.
        let _ = InstrumentDataDocumentController()
        
        // register the default preferences
        let defaultsDictionary = [kShowConnectionsPreferenceKey: true, kAnimateConnectionsPreferenceKey: true, kCutCornersPreferenceKey: true];
        UserDefaults.standard.register(defaults: defaultsDictionary)
        
    }
    
    // prevent the app from creating a new document
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Show the opening screen or jump straight into the open screen
        if Preferences.stopShowingStartScreen == false {
            let storyboard = NSStoryboard(name: kMainStoryboardIdentifier, bundle: nil)
            startScreenWindowController = storyboard.instantiateController(withIdentifier: kStartScreenWindowIdentifier) as? NSWindowController
            startScreenWindowController?.showWindow(self)
        } else {
            NSDocumentController.shared.openDocument(self)
        }
    }
}
