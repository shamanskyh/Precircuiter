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
    var fileEncoding: String.Encoding?
    
    /// an array of the possible fields on each instrument we import
    var headers: [String] = []
    
    override func makeWindowControllers() {
        
        // Returns the Storyboard that contains the Document window
        let storyboard = NSStoryboard(name: kMainStoryboardIdentifier, bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: kMainDocumentWindowIdentifier) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        
        // put UID second for easy import into Vectorworks
        headers = headers.sorted(by: { ($0 == "__UID" && $1 != "__UID") })
        headers = headers.sorted(by: { ($0 == "Device Type" && $1 != "Device Type") })
        
        var runningString: String = ""
        for header in headers {
            runningString += header
            runningString.append(("\t" as Character))
        }
        runningString = String(runningString.dropLast())  // remove the trailing tab
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
                    throw TextExportError.propertyNotFound
                }
            }
            runningString = String(runningString.dropLast())  // remove the trailing tab
            runningString.append(("\n" as Character))
        }
        
        guard let encoding = fileEncoding else {
            
            if let data = runningString.data(using: String.Encoding.macOSRoman) {
                return data
            }
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        if let data = runningString.data(using: encoding) {
            return data
        }
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        
        undoManager?.disableUndoRegistration()
        
        // TODO: Allow user to specify file encoding
        fileEncoding = String.Encoding.macOSRoman
        let rawFile = String(data: data, encoding: fileEncoding!)
        
        guard let importString = rawFile else {
            throw TextImportError.encodingError
        }
        
        var finishedHeaders: Bool = false
        var currentKeyword: String = ""
        var currentPosition: Int = 0
        var currentInstrument: Instrument = Instrument(UID: nil, location: nil, undoManager: self.undoManager)
        
        var tempLights: [Instrument] = []
        var tempDimmers: [Instrument] = []
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }

            for char in importString {
                if !finishedHeaders {
                    if char == "\t" {
                        strongSelf.headers.append(currentKeyword)
                        currentKeyword = ""
                    } else if char == "\n" || char == "\r" || char == "\r\n" {
                        strongSelf.headers.append(currentKeyword)
                        currentKeyword = ""
                        finishedHeaders = true
                    } else {
                        currentKeyword.append(char)
                    }
                } else {
                    if char == "\t" {
                        
                        guard currentPosition < strongSelf.headers.count else {
                            DispatchQueue.main.async { [weak strongSelf] in
                                strongSelf?.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        do {
                            try addPropertyToInstrument(&currentInstrument, propertyString: strongSelf.headers[currentPosition], propertyValue: currentKeyword)
                            currentPosition += 1
                        } catch InstrumentError.ambiguousLocation {
                            DispatchQueue.main.async { [weak strongSelf] in
                                strongSelf?.displayCouldNotImportPlotError()
                            }
                            return
                        } catch InstrumentError.propertyStringUnrecognized {
                            NSLog("Could not import property: \(strongSelf.headers[currentPosition - 1])")
                            continue
                        } catch {
                            DispatchQueue.main.async { [weak strongSelf] in
                                strongSelf?.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        currentKeyword = ""
                    } else if char == "\n" || char == "\r" || char == "\r\n" {
                        
                        guard currentPosition < strongSelf.headers.count else {
                            DispatchQueue.main.async { [weak strongSelf] in
                                strongSelf?.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        // finish the last property
                        do {
                            try addPropertyToInstrument(&currentInstrument, propertyString: strongSelf.headers[currentPosition], propertyValue: currentKeyword)
                        } catch InstrumentError.ambiguousLocation {
                            DispatchQueue.main.async { [weak strongSelf] in
                                strongSelf?.displayCouldNotImportPlotError()
                            }
                            return
                        } catch InstrumentError.propertyStringUnrecognized {
                            NSLog("Could not import property: \(strongSelf.headers[currentPosition])")
                            continue
                        } catch {
                            DispatchQueue.main.async { [weak strongSelf] in
                                strongSelf?.displayCouldNotImportPlotError()
                            }
                            return
                        }
                        
                        currentKeyword = ""
                        currentPosition = 0
                        currentInstrument.assignedBy = .outsideOfApplication
                        if currentInstrument.deviceType == .power {
                            tempDimmers.append(currentInstrument)
                        } else if currentInstrument.deviceType == .light ||
                            currentInstrument.deviceType == .movingLight ||
                            currentInstrument.deviceType == .practical {
                                tempLights.append(currentInstrument)
                        } else {
                            strongSelf.otherInstruments.append(currentInstrument)
                        }
                        currentInstrument = Instrument(UID: nil, location: nil, undoManager: strongSelf.undoManager)
                    } else {
                        currentKeyword.append(char)
                    }
                }
            }
            
            strongSelf.allLights = tempLights
            strongSelf.allDimmers = tempDimmers
            
            // throw an error if no lights or dimmers are found. Probably a garbage plot
            if strongSelf.allLights.count == 0 && strongSelf.allDimmers.count == 0 {
                DispatchQueue.main.async { [weak strongSelf] in
                    strongSelf?.displayCouldNotImportPlotError()
                }
                return
            }
            
            // if we don't have any locations, also return. the user probably forgot to export all field names.
            var foundLocation = false
            for light in strongSelf.allLights {
                if light.locations.count > 0 {
                    foundLocation = true
                    break
                }
            }
            guard foundLocation == true else {
                DispatchQueue.main.async { [weak strongSelf] in
                    strongSelf?.displayCouldNotImportPlotError()
                }
                return
            }
            
            // For any light that has a dimmer filled in, try to find the corresponding power object, and link that power object to the light as well (two-way link)
            for light in strongSelf.allLights.filter({ $0.dimmer != nil }) {
                connect(light: light, dimmers: strongSelf.allDimmers)
            }
            
            // TODO: there's probably a better way to do this, but it's not
            // going to block a thread since we're in an async block...
            while (strongSelf.mainWindowController == nil) {
                continue
            }
            
            DispatchQueue.main.async { [weak strongSelf] in
                guard let strongStrongSelf = strongSelf else { return }
                (strongStrongSelf.mainWindowController!.window?.contentViewController as! MainViewController).representedObject = strongStrongSelf
                strongStrongSelf.undoManager?.enableUndoRegistration()
            }
        }
    }

    override class var autosavesInPlace: Bool {
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
