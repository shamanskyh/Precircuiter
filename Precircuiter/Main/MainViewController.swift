//
//  MainViewController.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 8/25/14.
//  Copyright © 2014 Harry Shamansky. All rights reserved.
//

import Cocoa

/// The main view controller for Precircuiter
class MainViewController: NSViewController {
    
    /// an array of the possible fields on each instrument we import
    var headers: [String] {
        get {
            if let document = self.representedObject as? InstrumentDataDocument {
                return document.headers
            }
            return []
        }
        set {
            if let document = self.representedObject as? InstrumentDataDocument {
                document.headers = newValue
            }
        }
    }
    
    /// an array of all lights, moving lights, and practicals
    /// bound to the array controller in IB and observed in the table view
    dynamic var allLights: [Instrument] {
        get {
            if let document = self.representedObject as? InstrumentDataDocument {
                return document.allLights
            }
            return []
        }
        set {
            if let document = self.representedObject as? InstrumentDataDocument {
                document.allLights = newValue
            }
        }
    }
    
    /// an array of all dimmers
    var allDimmers: [Instrument] {
        get {
            if let document = self.representedObject as? InstrumentDataDocument {
                return document.allDimmers
            }
            return []
        }
        set {
            if let document = self.representedObject as? InstrumentDataDocument {
                document.allDimmers = newValue
            }
        }
    }
    
    /// an array to keep track of non-light and non-dimmer instruments that should
    /// still be written on export
    var otherInstruments: [Instrument] {
        get {
            if let document = self.representedObject as? InstrumentDataDocument {
                return document.otherInstruments
            }
            return []
        }
        set {
            if let document = self.representedObject as? InstrumentDataDocument {
                document.otherInstruments = newValue
            }
        }
    }
    
    /// the table view of lights, moving lights, and practicals
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var plotView: PlotView!
    @IBOutlet weak var plotContainerView: PlotContainerView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    /// an outlet to the array controller, to get its selected indexes
    @IBOutlet weak var arrayController: NSArrayController!
    
    /// the underlying document
    override var representedObject: AnyObject? {
        didSet {
            if let document = representedObject as? InstrumentDataDocument {
                
                allLights = document.allLights
                allDimmers = document.allDimmers
                otherInstruments = document.otherInstruments
                headers = document.headers
                
                // throw alert if there are no dimmers
                if allDimmers.count == 0 {
                    let alert = NSAlert()
                    alert.messageText = "No Dimmers Found"
                    alert.informativeText = "Precircuiter couldn't find any dimmers in this plot. Please be sure that your Vectorworks plot includes instrument symbols with \"Power\" as their device type and try again."
                    alert.runModal()
                }
                
                plotView.invalidateSymbolsAndRedraw()
                plotContainerView.spinner.stopAnimation(self)
                updateToolbar()
                
                // Sort the lights by position, then by unit number
                let sortDescriptor = NSSortDescriptor(key: "secondarySortKey", ascending: true, selector: "localizedStandardCompare:")
                allLights = (allLights as NSArray).sortedArrayUsingDescriptors([sortDescriptor]) as! [Instrument]
            }
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        plotView.delegate = self
        
        // refresh the toolbar if anything is undone/redone
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateToolbar", name: NSUndoManagerDidUndoChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateToolbar", name: NSUndoManagerDidRedoChangeNotification, object: nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        plotContainerView.spinner.startAnimation(self)
        updateToolbar()
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerDidUndoChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerDidRedoChangeNotification, object: nil)
    }

    // MARK: - Utilities
    func combineDuplicates(instruments: [Instrument], isDimmer: Bool, uniqueSplitter: Character) -> [Instrument] {
        
        view.window?.undoManager?.disableUndoRegistration()
        
        var copiedInstruments: [Instrument] = []
        for instrument in instruments {
            let instrumentCopy = instrument.copy() as! Instrument
            copiedInstruments.append(instrumentCopy)
        }
        
        var instrumentsToRemove: [Instrument] = []
        for i in 0..<copiedInstruments.count {
            let valueToMatch = isDimmer ? copiedInstruments[i].dimmer : copiedInstruments[i].channel
            for j in (i + 1)..<copiedInstruments.count {
                let valueToCheck = isDimmer ? copiedInstruments[j].dimmer : copiedInstruments[j].channel
                if valueToCheck == valueToMatch {
                    instrumentsToRemove.append(copiedInstruments[j])
                    copiedInstruments[i].locations += copiedInstruments[j].locations
                    copiedInstruments[i].UID += "\(uniqueSplitter)\(instruments[j].UID)"
                }
            }
        }
        
        for instrument in instrumentsToRemove {
            copiedInstruments.removeObject(instrument)
        }
        
        view.window?.undoManager?.enableUndoRegistration()
        
        return copiedInstruments
    }
    
    func explodeDuplicates(inout originalInstruments: [Instrument], compressedCopy: [Instrument], isDimmer: Bool, uniqueSplitter: Character) {
        for instrument in compressedCopy {
            // find the corresponding instruments from the originals
            let UIDs: [String] = instrument.UID.characters.split(){$0 == uniqueSplitter}.map(String.init)
            for originalInstrument in originalInstruments where UIDs.contains(originalInstrument.UID) {
                if isDimmer {
                    originalInstrument.channel = instrument.channel
                } else {
                    originalInstrument.dimmer = instrument.dimmer
                }
            }
        }
    }
    
    /// reloads the cell without reloading the entire row
    func softReloadCell(sender: AnyObject) {
        let rowToUpdate = self.tableView.rowForView(sender as! NSView)
        let columnToUpdate = self.tableView.columnForView(sender as! NSView)
        
        guard rowToUpdate < allLights.count && rowToUpdate >= 0 else {
            return
        }
        
        guard columnToUpdate < tableView.tableColumns.count && columnToUpdate >= 0 else {
            return
        }
        
        allLights[rowToUpdate].needsNewSwatchColor = true
        allLights[rowToUpdate].needsNewViewRepresentation = true
        
        if self.tableView.tableColumns[columnToUpdate].title == "Dimmer" {
            let light = allLights[rowToUpdate]
            
            light.assignedBy = .Manual
            light.receptacle?.light = nil
            
            if light.dimmer?.characters.count > 0 {
                connectLight(light, toClosestDimmer: allDimmers)
            } else {
                light.receptacle = nil
            }
        }
        
        plotView.invalidateSymbolsAndRedraw()
        updateToolbar()
    }

    // MARK: - IB Actions
    /// A method to reload a cell from one of its inner views.
    /// For example, we might want to update the entire cell (including the swatch
    /// if the color cell is updated).
    @IBAction func reloadCell(sender: AnyObject) {
        let rowToUpdate = self.tableView.rowForView(sender as! NSView)
        let columnToUpdate = self.tableView.columnForView(sender as! NSView)
        
        allLights[rowToUpdate].needsNewSwatchColor = true
        allLights[rowToUpdate].needsNewViewRepresentation = true
        
        plotView.invalidateSymbolsAndRedraw()
        
        tableView.reloadDataForRowIndexes(NSIndexSet(index: rowToUpdate), columnIndexes: NSIndexSet(index: columnToUpdate))
        
        updateToolbar()
    }
    
    /// Mark the dimmer as manually modified
    @IBAction func manuallyModifyDimmer(sender: AnyObject) {
        let rowToUpdate = self.tableView.rowForView(sender as! NSView)
        
        guard rowToUpdate < allLights.count && rowToUpdate >= 0 else {
            return
        }
        
        let light = allLights[rowToUpdate]
        
        light.assignedBy = .Manual
        light.receptacle?.light = nil
        
        if light.dimmer?.characters.count > 0 {
            connectLight(light, toClosestDimmer: allDimmers)
        } else {
            light.receptacle = nil
        }
        
        plotView.invalidateSymbolsAndRedraw()
        
        updateToolbar()
    }
}

// MARK: - NSTableViewDelegate
extension MainViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(notification: NSNotification) {
        
        allLights.forEach({ $0.selected = false })
        
        for light in arrayController.selectedObjects as! [Instrument] {
            light.selected = true
        }
        
        plotView.invalidateSymbolsAndRedraw()
        plotView.needsDisplay = true
    }
}

// MARK: - NSControlTextEditingDelegate
extension MainViewController: NSControlTextEditingDelegate {
    func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        
        let row = tableView.rowForView(textView)
        let column = tableView.columnForView(textView)
        
        if commandSelector == "insertNewline:" || commandSelector == "moveDown:" {
            if row < tableView.numberOfRows - 1 {
                tableView.selectRowIndexes(NSIndexSet(index: row + 1), byExtendingSelection: false)
                tableView.editColumn(column, row: row + 1, withEvent: nil, select: true)
            }
            softReloadCell(textView)
            return true
        } else if commandSelector == "moveUp:" {
            if row > 0 {
                tableView.selectRowIndexes(NSIndexSet(index: row - 1), byExtendingSelection: false)
                tableView.editColumn(column, row: row - 1, withEvent: nil, select: true)
            }
            softReloadCell(textView)
            return true
        } else if commandSelector == "insertTab:" {
            if column < tableView.numberOfColumns - 1 {
                tableView.editColumn(column + 1, row: row, withEvent: nil, select: true)
            } else {
                tableView.selectRowIndexes(NSIndexSet(index: row + 1), byExtendingSelection: false)
                tableView.editColumn(0, row: row + 1, withEvent: nil, select: true)
            }
            softReloadCell(textView)
            return true
        } else if commandSelector == "insertBacktab:" {
            if column > 0 {
                tableView.editColumn(column - 1, row: row, withEvent: nil, select: true)
            } else if row > 0 {
                tableView.selectRowIndexes(NSIndexSet(index: row - 1), byExtendingSelection: false)
                tableView.editColumn(tableView.numberOfColumns - 1, row: row - 1, withEvent: nil, select: true)
            }
            softReloadCell(textView)
            return true
        }
        return false
    }
}

// MARK: - PlotViewDelegate
extension MainViewController: PlotViewDelegate {
    
    func getLights() -> [Instrument] {
        return allLights
    }
    
    func getDimmers() -> [Instrument] {
        return allDimmers
    }
    
    func updateSelectedLights(selectedLights: [Instrument], selectDimmers: Bool) {
        allLights.forEach({ $0.selected = false })
        selectedLights.forEach({ $0.selected = true })
        
        plotView.invalidateSymbolsAndRedraw()
        plotView.needsDisplay = true
        
        // select the corresponding row(s) in the table view
        let indexSet = NSMutableIndexSet()
        for light in selectedLights {
            if let index = allLights.indexOf(light) {
                indexSet.addIndex(index)
            }
        }
        
        if selectDimmers {
            let correspondingDimmers: [Instrument] = selectedLights.filter({ $0.receptacle != nil }).map({ $0.receptacle! })
            updateSelectedDimmers(correspondingDimmers, selectLights: false)
        }

        if selectedLights.count == 0 {
            tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            return  // don't scroll if it's a deselection
        }
        
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
            context.allowsImplicitAnimation = true
            context.duration = 0.5
            self.tableView.scrollRowToVisible(indexSet.firstIndex)
            }, completionHandler: {
                self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
        })
        
    }
    
    func updateSelectedDimmers(selectedDimmers: [Instrument], selectLights: Bool) {
        allDimmers.forEach({ $0.selected = false })
        selectedDimmers.forEach({ $0.selected = true })

        if selectLights {
            let correspondingLights: [Instrument] = selectedDimmers.filter({ $0.light != nil }).map({ $0.light! })
            updateSelectedLights(correspondingLights, selectDimmers: false)
        }
        
        plotView.invalidateSymbolsAndRedraw()
        plotView.needsDisplay = true
    }
}

// MARK: - MainWindowControllerDelegate
extension MainViewController: MainWindowControllerDelegate {
    
    /// These two functions do the heavy lifting and pair up instruments with dimmers.
    func assignMissingDimmers() {
        
        view.window?.undoManager?.disableUndoRegistration()
        
        var compressedLights = self.combineDuplicates(self.allLights.filter({ $0.dimmer == nil }), isDimmer: false, uniqueSplitter: kUniqueSplitterCharacter)
        var compressedDimmers = self.combineDuplicates(self.allDimmers.filter({ $0.light == nil }), isDimmer: true, uniqueSplitter: kUniqueSplitterCharacter)
        
        guard compressedLights.count > 0 && compressedDimmers.count > 0 else {
            return
        }
        
        let hungarianMatrix = HungarianMatrix(rows: compressedDimmers.count, columns: compressedDimmers.count)
        hungarianMatrix.delegate = self
        hungarianMatrix.assignAndPair(&compressedLights, dimmers: &compressedDimmers, cutCorners: Preferences.cutCorners) {
            self.view.window?.undoManager?.enableUndoRegistration()
            self.view.window?.undoManager?.beginUndoGrouping()
            
            self.explodeDuplicates(&self.allLights, compressedCopy: compressedLights.filter({ $0.dummyInstrument != true }), isDimmer: false, uniqueSplitter: kUniqueSplitterCharacter)
            self.explodeDuplicates(&self.allDimmers, compressedCopy: compressedDimmers.filter({ $0.dummyInstrument != true }), isDimmer: false, uniqueSplitter: kUniqueSplitterCharacter)
            // register the undo
            self.view.window?.undoManager?.setActionName("Assign Missing Dimmers to Lights")
            
            // For any light that has a dimmer filled in, try to find the corresponding power object, and link that power object to the light as well (two-way link)
            for light in self.allLights.filter({ $0.dimmer != nil }) {
                connectLight(light, toClosestDimmer: self.allDimmers)
            }
            
            if Preferences.showConnections {
                if let windowController = self.view.window?.windowController as? MainWindowController {
                    windowController.viewFilter.integerValue = PlotViewFilterType.Both.rawValue
                }
                self.plotView.filter = PlotViewFilterType.Both
                self.plotView.invalidateSymbolsAndRedraw()
                
                if Preferences.animateConnections {
                    self.plotView.animateInConnections()
                }
            } else {
                self.plotView.invalidateSymbolsAndRedraw()
            }
        
            self.updateToolbar()
            self.view.window?.undoManager?.endUndoGrouping()
        }
    }
    
    func assignAllDimmers() {
        
        // clear out existing links
        self.allLights.forEach({ $0.dimmer = nil })
        self.allLights.forEach({ $0.receptacle = nil })
        self.allDimmers.forEach({ $0.light = nil })
        
        view.window?.undoManager?.disableUndoRegistration()
        
        var compressedLights = self.combineDuplicates(self.allLights, isDimmer: false, uniqueSplitter: kUniqueSplitterCharacter)
        var compressedDimmers = self.combineDuplicates(self.allDimmers, isDimmer: true, uniqueSplitter: kUniqueSplitterCharacter)
        let hungarianMatrix = HungarianMatrix(rows: compressedDimmers.count, columns: compressedDimmers.count)
        
        guard compressedLights.count > 0 && compressedDimmers.count > 0 else {
            return
        }
        
        hungarianMatrix.delegate = self
        hungarianMatrix.assignAndPair(&compressedLights, dimmers: &compressedDimmers, cutCorners: Preferences.cutCorners
            ) {
                self.view.window?.undoManager?.enableUndoRegistration()
                
                self.explodeDuplicates(&self.allLights, compressedCopy: compressedLights.filter({ $0.dummyInstrument != true }), isDimmer: false, uniqueSplitter: kUniqueSplitterCharacter)
                self.explodeDuplicates(&self.allDimmers, compressedCopy: compressedDimmers.filter({ $0.dummyInstrument != true }), isDimmer: false, uniqueSplitter: kUniqueSplitterCharacter)
                // register the undo
                self.view.window?.undoManager?.setActionName("Assign All Dimmers to Lights")
                
                // For any light that has a dimmer filled in, try to find the corresponding power object, and link that power object to the light as well (two-way link)
                for light in self.allLights.filter({ $0.dimmer != nil }) {
                    connectLight(light, toClosestDimmer: self.allDimmers)
                }
                
                if Preferences.showConnections {
                    if let windowController = self.view.window?.windowController as? MainWindowController {
                        windowController.viewFilter.integerValue = PlotViewFilterType.Both.rawValue
                    }
                    self.plotView.filter = PlotViewFilterType.Both
                    self.plotView.invalidateSymbolsAndRedraw()
                    
                    if Preferences.animateConnections {
                        self.plotView.animateInConnections()
                    }
                } else {
                    self.plotView.invalidateSymbolsAndRedraw()
                }
                
                self.updateToolbar()
        }
    }
    
    func updateToolbar() {
        if let windowController = self.view.window?.windowController as? MainWindowController {
            windowController.updateToolbar()
        }
    }
    
    var shouldWarnAboutOverwrite: Bool {
        return (allLights.count > 0 || allDimmers.count > 0)
    }
    
    var hasMissingDimmers: Bool {
        return allLights.filter({ $0.dimmer == nil || $0.dimmer == "" }).count > 0
    }
    
    func updateFilter(selection: PlotViewFilterType) {
        self.plotView.filter = selection
    }
}

// MARK: - HungarianMatrixDelegate
extension MainViewController: HungarianMatrixDelegate {
    func didUpdateProgress(progress: Double) {
        
        dispatch_async(dispatch_get_main_queue(), {
            if progress >= 1.0 {
                self.progressIndicator.hidden = true
                self.progressIndicator.minValue = 0.0
                self.tableView.reloadData()
            } else if self.progressIndicator.minValue == 0.0 {
                
                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.duration = 2.0
                    self.progressIndicator.minValue = max(progress, 0.1)
                }, completionHandler: nil)
                
                self.progressIndicator.hidden = false
            } else {
                self.progressIndicator.doubleValue = progress
            }
        })
    }
}
