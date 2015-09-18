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
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        
        // Create an instance of the sub-classed document controller.
        // This will be set as the shared document controller, according to the spec.
        let _ = InstrumentDataDocumentController()
        
        // register the default preferences
        let defaultsDictionary = [kShowConnectionsPreferenceKey: true, kAnimateConnectionsPreferenceKey: true, kCutCornersPreferenceKey: true];
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultsDictionary)
        
    }
    
    // prevent the app from creating a new document
    func applicationShouldOpenUntitledFile(sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Show the opening screen or jump straight into the open screen
        if Preferences.stopShowingStartScreen == false {
            let storyboard = NSStoryboard(name: kMainStoryboardIdentifier, bundle: nil)
            startScreenWindowController = storyboard.instantiateControllerWithIdentifier(kStartScreenWindowIdentifier) as? NSWindowController
            startScreenWindowController?.showWindow(self)
        } else {
            NSDocumentController.sharedDocumentController().openDocument(self)
        }
    }
}
