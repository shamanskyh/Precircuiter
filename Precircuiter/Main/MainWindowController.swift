//
//  MainWindowController.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 8/27/14.
//  Copyright © 2014 Harry Shamansky. All rights reserved.
//

import Cocoa

protocol MainWindowControllerDelegate {
    func assignMissingDimmers()
    func assignAllDimmers()
    func updateFilter(selection: PlotViewFilterType)
    var shouldWarnAboutOverwrite: Bool { get }
    var hasMissingDimmers: Bool { get }
}

/// An enumeration that corresponds to the segmented control layout
enum PlotViewFilterType: Int {
    case Lights = 0
    case Dimmers = 1
    case Both = 2
}

class MainWindowController: NSWindowController {

    var delegate: MainWindowControllerDelegate? = nil
    var overwriteOnImport: Bool = false
    @IBOutlet weak var assignMissingToolbarItem: NSToolbarItem!
    @IBOutlet weak var assignAllToolbarItem: NSToolbarItem!
    @IBOutlet weak var viewFilter: NSSegmentedControl!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        delegate = (self.contentViewController as! MainViewController)
        updateToolbar()
    }
    
    func updateToolbar() {
        assignMissingToolbarItem.enabled = hasMissingDimmers
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.action == "assignMissingDimmers:" {
            return hasMissingDimmers
        }
        return true
    }
    
    @IBAction func assignMissingDimmers(sender: AnyObject) {
        delegate?.assignMissingDimmers()
    }
    
    @IBAction func assignAllDimmers(sender: AnyObject) {
        delegate?.assignAllDimmers()
    }
    
    @IBAction func changeFilter(sender: AnyObject) {
        delegate?.updateFilter(PlotViewFilterType.init(rawValue: (sender as! NSSegmentedControl).integerValue)!)
    }
    
    var hasMissingDimmers: Bool {
        if let delegate = delegate {
            return delegate.hasMissingDimmers
        } else {
            return true
        }
    }
}