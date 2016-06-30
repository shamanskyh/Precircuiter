//
//  PreferencesViewController.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/21/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func changeDrawingPreferences(_ sender: AnyObject) {
        NotificationCenter.default().post(Notification(name: NSNotification.Name(rawValue: kShouldReloadPlotViewNotification), object: nil))
    }
    
    @IBAction func resetStartupWindow(_ sender: AnyObject) {
        Preferences.stopShowingStartScreen = false
    }
}
