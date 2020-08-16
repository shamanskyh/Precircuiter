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
    func updateFilter(_ selection: PlotViewFilterType)
    var shouldWarnAboutOverwrite: Bool { get }
    var hasMissingDimmers: Bool { get }
}

/// An enumeration that corresponds to the segmented control layout
enum PlotViewFilterType: Int {
    case lights = 0
    case dimmers = 1
    case both = 2
}

class MainWindowController: NSWindowController {

    var delegate: MainWindowControllerDelegate? = nil
    var overwriteOnImport: Bool = false
    @IBOutlet weak var assignMissingToolbarItem: NSToolbarItem!
    @IBOutlet weak var assignAllToolbarItem: NSToolbarItem!
    @IBOutlet weak var viewFilter: NSSegmentedControl!
    @IBOutlet weak var assignMissingTouchBarButton: NSButton!
    @IBOutlet weak var viewFilterTouchBar: NSSegmentedControl!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        delegate = (self.contentViewController as! MainViewController)
        updateToolbar()
    }
    
    func updateToolbar() {
        let enabled = hasMissingDimmers
        assignMissingToolbarItem.isEnabled = enabled
        assignMissingTouchBarButton.isEnabled = enabled
    }
    
    func updateOtherSegmentedControl(sender: NSSegmentedControl, index: Int) {
        if sender == viewFilter {
            viewFilterTouchBar.integerValue = index
        } else {
            viewFilter.integerValue = index
        }
    }
    
    @IBAction func assignMissingDimmers(_ sender: AnyObject) {
        delegate?.assignMissingDimmers()
    }
    
    @IBAction func assignAllDimmers(_ sender: AnyObject) {
        delegate?.assignAllDimmers()
    }
    
    @IBAction func changeFilter(_ sender: AnyObject) {
        if let segmentedControl = sender as? NSSegmentedControl {
            let index = segmentedControl.integerValue
            if let filterType = PlotViewFilterType(rawValue: index) {
                delegate?.updateFilter(filterType)
            }
            updateOtherSegmentedControl(sender: segmentedControl, index: index)
        }
    }
    
    @objc var hasMissingDimmers: Bool {
        if let delegate = delegate {
            return delegate.hasMissingDimmers
        } else {
            return true
        }
    }
}
