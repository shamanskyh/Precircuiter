//
//  Instrument.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 7/26/14.
//  Copyright © 2014 Harry Shamansky. All rights reserved.
//

import Cocoa

// MARK: - Enumerations
enum DeviceType {
    case light
    case movingLight
    case accessory
    case staticAccessory
    case device
    case practical
    case sfx
    case power
    case other
    
    var description: String {
        switch self {
        case .light: return "Light"
        case .movingLight: return "MovingLight"
        case .accessory: return "Accessory"
        case .staticAccessory: return "StaticAccessory"
        case .device: return "Device"
        case .practical: return "Practical"
        case .sfx: return "SFX"
        case .power: return "Power"
        case .other: return "Other"
        }
    }
}

enum Patcher: Int {
    case unknown
    case outsideOfApplication   // VWX, Lightwright, or other
    case auto                   // Automatically assigned
    case manual                 // Manually assigned *in Precircuiter*
}

enum Dimension {
    case x
    case y
    case z
}

// MARK: - Structs
struct Coordinate {
    var x: Double
    var y: Double
    var z: Double
    init(xPos: Double, yPos: Double, zPos: Double) {
        x = xPos
        y = yPos
        z = zPos
    }
}

// MARK: - Instrument Class
class Instrument: NSObject {
    
    var dummyInstrument: Bool
    
    var deviceType: DeviceType? = nil
    var instrumentType: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.instrumentType), object: instrumentType)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Instrument Type")
        }
    }
    var wattage: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.wattage), object: wattage)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Wattage")
        }
    }
    var purpose: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.purpose), object: purpose)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Purpose")
        }
    }
    var position: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.position), object: position)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Position")
        }
    }
    var unitNumber: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.unitNumber), object: unitNumber)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Unit Number")
        }
    }
    var color: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.color), object: color)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Color")
        }
    }
    var dimmer: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.dimmer), object: dimmer)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Dimmer")
        }
    }
    var channel: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.channel), object: channel)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Channel")
        }
    }
    var address: String? = nil
    var universe: String? = nil
    var uAddress: String? = nil
    var uDimmer: String? = nil
    var circuitNumber: String? = nil
    var circuitName: String? = nil
    var system: String? = nil
    var userField1: String? = nil
    var userField2: String? = nil
    var userField3: String? = nil
    var userField4: String? = nil
    var userField5: String? = nil
    var userField6: String? = nil
    var numChannels: String? = nil
    var frameSize: String? = nil
    var fieldAngle: String? = nil
    var fieldAngle2: String? = nil
    var beamAngle: String? = nil
    var beamAngle2: String? = nil
    var weight: String? = nil
    var gobo1: String? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.gobo1), object: gobo1)
            NSApplication.shared().mainWindow?.undoManager?.setActionName("Modify Gobo 1")
        }
    }
    var gobo1Rotation: String? = nil
    var gobo2: String? = nil
    var gobo2Rotation: String? = nil
    var goboShift: String? = nil
    var mark: String? = nil
    var drawBeam: Bool? = nil
    var drawBeamAs3DSolid: Bool? = nil
    var useVerticalBeam: Bool? = nil
    var showBeamAt: String? = nil
    var falloffDistance: String? = nil
    var lampRotationAngle: String? = nil
    var topShutterDepth: String? = nil
    var topShutterAngle: String? = nil
    var leftShutterDepth: String? = nil
    var leftShutterAngle: String? = nil
    var rightShutterDepth: String? = nil
    var rightShutterAngle: String? = nil
    var bottomShutterDepth: String? = nil
    var bottomShutterAngle: String? = nil
    var symbolName: String? = nil
    var useLegend: Bool? = nil
    var flipFrontBackLegendText: Bool? = nil
    var flipLeftRightLegendText: Bool? = nil
    var focus: String? = nil
    var set3DOrientation: Bool? = nil
    var xRotation: String? = nil
    var yRotation: String? = nil
    var locations: [Coordinate] = []
    var rawXLocation: String? = nil
    var rawYLocation: String? = nil
    var rawZLocation: String? = nil
    var fixtureID: String? = nil
    var UID: String
    var accessories: String? = nil
    
    // MARK: - Binding Properties
    var secondarySortKey: String? {
        if self.position != nil || self.unitNumber != nil {
            return "\(self.position)\(self.unitNumber)"
        }
        return nil
    }
    
    
    private var savedSwatchColor: NSColor?
    private var isClearColor: Bool {
        return color?.trimmingCharacters(in: .whitespaces) == "N/C" ||
               color?.trimmingCharacters(in: .whitespaces) == "NC"
    }
    internal var needsNewSwatchColor = false
    internal var swatchColor: NSColor? {
        if (savedSwatchColor == nil && color != nil) || needsNewSwatchColor {
            needsNewSwatchColor = false
            if let color = self.color?.toGelColor() {
                savedSwatchColor = NSColor(cgColor: color)
            } else {
                savedSwatchColor = nil
            }
        }
        return savedSwatchColor
    }
    
    // MARK: - Drawing for PlotView
    internal var selected: Bool = false
    internal var needsNewViewRepresentation = false
    private var savedView: NSView?
    internal var viewRepresentation: NSView {
        if savedView != nil && needsNewViewRepresentation == false {
            return savedView!
        }

        needsNewViewRepresentation = false
        if let v = savedView {
            v.removeFromSuperview()
            savedView = nil
        }
        
        if self.deviceType == .power {
            let view = DimmerSymbolView()
            view.frame.size = kDefaultDimmerSymbolSize
            view.dimmer = self.dimmer
            view.dimmerInstrument = self
            self.savedView = view
            return view
        }
        
        let view = LightSymbolView()
        view.selected = self.selected
        view.frame.size = kDefaultLightSymbolSize
        view.channel = self.channel
        view.lightInstrument = self
        view.color = self.isClearColor ? nil : self.swatchColor
        self.savedView = view
        return view
    }
    
    internal func setViewRepresentationFrame(_ frame: CGRect) {
        self.savedView?.frame = frame
    }
    
    // MARK: - Other Functions
    
    // use only if power
    weak var light: Instrument? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.light), object: light)
        }
    }
    
    // use only if non-power
    weak var receptacle: Instrument? = nil {
        willSet {
            NSApplication.shared().mainWindow?.undoManager?.registerUndo(withTarget: self, selector: #selector(setter: Instrument.receptacle), object: receptacle)
        }
    }
    
    // to determine who patched
    var assignedBy: Patcher = Patcher.unknown
    
    /// private helper function to allow the assignedBy variable to be set with an object
    internal func setAssignedByWithObject(_ value: NSNumber) {
        self.assignedBy = Patcher(rawValue: value.intValue)!
    }
    
    required init(UID: String?, location: [Coordinate]?) {
        
        if let id = UID {
            self.UID = id
        } else {
            self.UID = ""
        }
        if let loc = location {
            self.locations = loc
        } else {
            self.locations = []
        }
        
        self.dummyInstrument = false
    }
    
    func addCoordinateToInitialLocation(_ type: Dimension, value: String) throws {
    
        var coord = self.locations.first
        if coord == nil {
           coord = Coordinate(xPos: 0.0, yPos: 0.0, zPos: 0.0)
        } else if self.locations.count > 1 {
            throw InstrumentError.ambiguousLocation
        }
        
        var convertedValue: Double = 0.0;
        do {
            try convertedValue = value.unknownUnitToMeters()
        } catch {
            throw InstrumentError.unrecognizedCoordinate
        }
        
        switch type {
            case .x: coord!.x = convertedValue
            case .y: coord!.y = convertedValue
            case .z: coord!.z = convertedValue
        }
        
        self.locations = [coord!]
    }
    
    /// Overrides the description and prints a custom description.
    /// Used in the tool tooltip of the plot view.
    override var description: String {
        var runningString = ""
        
        if self.deviceType == .light, let channel = self.channel {
            runningString += "Light (\(channel))"
            if let dimmer = self.dimmer {
                runningString += "\nDimmer [\(dimmer)]"
            }
            runningString += ""
        } else if self.deviceType == .power, let dimmer = self.dimmer {
            runningString += "Dimmer [\(dimmer)]"
            if let light = self.light, let channel = light.channel {
                runningString += "\nChannel (\(channel))"
            }
        } else if let deviceType = self.deviceType?.description {
            runningString += deviceType
        }
        
        if let position = self.position {
            if let unitNumber = self.unitNumber {
                runningString += "\n—\n\(position), Unit \(unitNumber)"
            } else {
                runningString += "\n—\n\(position)"
            }
        } else if let unitNumber  = self.unitNumber {
            runningString += "\n—\nUnit \(unitNumber)"
        }
        
        if let instrumentType = self.instrumentType {
            runningString += ("\n—\n" + instrumentType)
        }
        if let wattage = self.wattage {
            runningString += ("\n" + wattage)
        }
        
        if let purpose = self.purpose {
            runningString += ("\n—\n" + purpose)
        }
        
        if let color = self.color {
            runningString += ("\n" + color)
        }
        if let gobo = self.gobo1 {
            runningString += ("\n" + gobo)
        }
        
        guard runningString.characters.count > 0 else {
            return super.description
        }
        return runningString
    }
    
}

// MARK: - NSCopying Protocol Conformance
extension Instrument: NSCopying {
    func copy(with zone: NSZone?) -> Any {
        let copy = type(of: self).init(UID: self.UID, location: self.locations)
        copy.dummyInstrument = self.dummyInstrument
        copy.deviceType = self.deviceType
        copy.instrumentType = self.instrumentType
        copy.wattage = self.wattage
        copy.purpose = self.purpose
        copy.position = self.position
        copy.unitNumber = self.unitNumber
        copy.color = self.color
        copy.dimmer = self.dimmer
        copy.channel = self.channel
        copy.address = self.address
        copy.universe = self.universe
        copy.uAddress = self.uAddress
        copy.uDimmer = self.uDimmer
        copy.circuitNumber = self.circuitNumber
        copy.circuitName = self.circuitName
        copy.system = self.system
        copy.userField1 = self.userField1
        copy.userField2 = self.userField2
        copy.userField3 = self.userField3
        copy.userField4 = self.userField4
        copy.userField5 = self.userField5
        copy.userField6 = self.userField6
        copy.numChannels = self.numChannels
        copy.frameSize = self.frameSize
        copy.fieldAngle = self.fieldAngle
        copy.fieldAngle2 = self.fieldAngle2
        copy.beamAngle = self.beamAngle
        copy.beamAngle2 = self.beamAngle2
        copy.weight = self.weight
        copy.gobo1 = self.gobo1
        copy.gobo1Rotation = self.gobo1Rotation
        copy.gobo2 = self.gobo2
        copy.gobo2Rotation = self.gobo2Rotation
        copy.goboShift = self.goboShift
        copy.mark = self.mark
        copy.drawBeam = self.drawBeam
        copy.drawBeamAs3DSolid = self.drawBeamAs3DSolid
        copy.useVerticalBeam = self.useVerticalBeam
        copy.showBeamAt = self.showBeamAt
        copy.falloffDistance = self.falloffDistance
        copy.lampRotationAngle = self.lampRotationAngle
        copy.topShutterDepth = self.topShutterDepth
        copy.topShutterAngle = self.topShutterAngle
        copy.leftShutterDepth = self.leftShutterDepth
        copy.leftShutterAngle = self.leftShutterAngle
        copy.rightShutterDepth = self.rightShutterDepth
        copy.rightShutterAngle = self.rightShutterAngle
        copy.bottomShutterDepth = self.bottomShutterDepth
        copy.bottomShutterAngle = self.bottomShutterAngle
        copy.symbolName = self.symbolName
        copy.useLegend = self.useLegend
        copy.flipFrontBackLegendText = self.flipFrontBackLegendText
        copy.flipLeftRightLegendText = self.flipLeftRightLegendText
        copy.focus = self.focus
        copy.set3DOrientation = self.set3DOrientation
        copy.xRotation = self.xRotation
        copy.yRotation = self.yRotation
        copy.rawXLocation = self.rawXLocation
        copy.rawYLocation = self.rawYLocation
        copy.rawZLocation = self.rawZLocation
        copy.fixtureID = self.fixtureID
        copy.accessories = self.accessories
        
        copy.light = self.light
        copy.receptacle = self.receptacle
        copy.assignedBy = self.assignedBy
        
        return copy
    }
}

