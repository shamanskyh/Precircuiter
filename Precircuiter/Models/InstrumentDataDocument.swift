//
//  InstrumentDataDocument.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/6/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class InstrumentDataDocument: NSDocument {
    
    /// an array of all lights, moving lights, and practicals
    /// bound to the array controller in IB and observed in the table view
    dynamic var allLights: [Instrument] = []
    
    /// an array of all dimmers
    var allDimmers: [Instrument] = []
    
    /// an array to keep track of non-light and non-dimmer instruments that should
    /// still be written on export
    var otherInstruments: [Instrument] = []
    
    /// a way of keeping track of the encoding so that we export as we imported
    var fileEncoding: UInt?
    
    /// an array of the possible fields on each instrument we import
    var headers: [String] = []
    
    override func makeWindowControllers() {
        
        // Returns the Storyboard that contains the Document window
        let storyboard = NSStoryboard(name: kMainStoryboardIdentifier, bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier(kMainDocumentWindowIdentifier) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func dataOfType(typeName: String) throws -> NSData {
        
        // put UID second for easy import into Vectorworks
        headers.sortInPlace({ ($0 == "__UID" && $1 != "__UID") })
        headers.sortInPlace({ ($0 == "Device Type" && $1 != "Device Type") })
        
        var runningString: String = ""
        for header in headers {
            runningString += header
            runningString.append(("\t" as Character))
        }
        runningString = String(runningString.characters.dropLast())  // remove the trailing tab
        runningString.append(("\n" as Character))
        
        for inst in allLights + allDimmers + otherInstruments {
            for header in headers {
                do {
                    if let item = try getPropertyFromInstrument(inst, propertyString: header) {
                        runningString += item
                    } else {
                        runningString += "-"
                    }
                    runningString.append(("\t" as Character))
                } catch {
                    throw TextExportError.PropertyNotFound
                }
            }
            runningString = String(runningString.characters.dropLast())  // remove the trailing tab
            runningString.append(("\n" as Character))
        }
        
        guard let encoding = fileEncoding else {
            
            if let data = runningString.dataUsingEncoding(NSMacOSRomanStringEncoding) {
                return data
            }
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        if let data = runningString.dataUsingEncoding(encoding) {
            return data
        }
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func readFromData(data: NSData, ofType typeName: String) throws {
        
        undoManager?.disableUndoRegistration()
        
        // TODO: Allow user to specify file encoding
        fileEncoding = NSMacOSRomanStringEncoding
        let rawFile = String(data: data, encoding: fileEncoding!)
        
        guard let importString = rawFile else {
            throw TextImportError.EncodingError
        }
        
        var finishedHeaders: Bool = false
        var currentKeyword: String = ""
        var currentPosition: Int = 0
        var currentInstrument: Instrument = Instrument(UID: nil, location: nil)
        
        var tempLights: [Instrument] = []
        var tempDimmers: [Instrument] = []
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            for char in importString.characters {
                if !finishedHeaders {
                    if char == "\t" {
                        self.headers.append(currentKeyword)
                        currentKeyword = ""
                    } else if char == "\n" || char == "\r" || char == "\r\n" {
                        self.headers.append(currentKeyword)
                        currentKeyword = ""
                        finishedHeaders = true
                    } else {
                        currentKeyword.append(char)
                    }
                } else {
                    if char == "\t" {
                        
                        guard currentPosition < self.headers.count else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        do {
                            try addPropertyToInstrument(&currentInstrument, propertyString: self.headers[currentPosition++], propertyValue: currentKeyword)
                        } catch InstrumentError.AmbiguousLocation {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayCouldNotImportPlotError()
                            }
                            return
                        } catch InstrumentError.PropertyStringUnrecognized {
                            print("Could not import property: \(self.headers[currentPosition - 1])")
                            continue
                        } catch {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        currentKeyword = ""
                    } else if char == "\n" || char == "\r" || char == "\r\n" {
                        
                        guard currentPosition < self.headers.count else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        // finish the last property
                        do {
                            try addPropertyToInstrument(&currentInstrument, propertyString: self.headers[currentPosition], propertyValue: currentKeyword)
                        } catch InstrumentError.AmbiguousLocation {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayCouldNotImportPlotError()
                            }
                            return
                        } catch InstrumentError.PropertyStringUnrecognized {
                            print("Could not import property: \(self.headers[currentPosition])")
                            continue
                        } catch {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        currentKeyword = ""
                        currentPosition = 0
                        currentInstrument.assignedBy = .OutsideOfApplication
                        if currentInstrument.deviceType == .Power {
                            tempDimmers.append(currentInstrument)
                        } else if currentInstrument.deviceType == .Light ||
                            currentInstrument.deviceType == .MovingLight ||
                            currentInstrument.deviceType == .Practical {
                                tempLights.append(currentInstrument)
                        } else {
                            self.otherInstruments.append(currentInstrument)
                        }
                        currentInstrument = Instrument(UID: nil, location: nil)
                    } else {
                        currentKeyword.append(char)
                    }
                }
            }
            
            self.allLights = tempLights
            self.allDimmers = tempDimmers
            
            // throw an error if no lights or dimmers are found. Probably a garbage plot
            if self.allLights.count == 0 && self.allDimmers.count == 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayCouldNotImportPlotError()
                }
                return
            }
            
            // if we don't have any locations, also return. the user probably forgot to export all field names.
            var foundLocation = false
            for light in self.allLights {
                if light.locations.count > 0 {
                    foundLocation = true
                    break
                }
            }
            guard foundLocation == true else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayCouldNotImportPlotError()
                }
                return
            }
            
            // For any light that has a dimmer filled in, try to find the corresponding power object, and link that power object to the light as well (two-way link)
            for light in self.allLights.filter({ $0.dimmer != nil }) {
                connectLight(light, toClosestDimmer: self.allDimmers)
            }
            
            // TODO: there's probably a better way to do this, but it's not
            // going to block a thread since we're in an async block...
            while (self.mainWindowController == nil) {
                continue
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                (self.mainWindowController!.window?.contentViewController as! MainViewController).representedObject = self
            }
            
            self.undoManager?.enableUndoRegistration()
        }
    }

    override class func autosavesInPlace() -> Bool {
        return false
    }

    var mainWindowController: MainWindowController? {
        return self.windowControllers.filter({ $0 is MainWindowController }).first as? MainWindowController
    }
    
    func displayCouldNotImportPlotError() {
        let alert = NSAlert()
        alert.messageText = "Error Importing Plot"
        alert.informativeText = "Precircuiter could not read the instrument data from this file. Please ensure that you are opening instrument data that you exported from Vectorworks using the File > Export menu.\n\nAlso ensure that all parameters were exported, with the field names exported as the first record.\n\nNote that this is NOT the same as the .xml file that Lightwright uses."
        mainWindowController?.window?.orderOut(self)
        alert.runModal()
    }
}