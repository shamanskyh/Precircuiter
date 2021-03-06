//
//  Utilities.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/9/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Foundation
import AppKit

// XOR Operator - from https://gist.github.com/JadenGeller/8afdbaa6cf8bf30bf645
precedencegroup BooleanPrecedence { associativity: left }
infix operator ^^ : BooleanPrecedence
func ^^(lhs: Bool, rhs: Bool) -> Bool {
    return lhs != rhs
}

/// Extension to determine whether a color is light or dark
extension NSColor {
    func isLight() -> Bool {
        let convertedColor = self.usingColorSpace(NSColorSpace.genericRGB)
        let red = convertedColor?.redComponent
        let green = convertedColor?.greenComponent
        let blue = convertedColor?.blueComponent
        
        guard let r = red, let b = blue, let g = green else {
            return true // default to dark text
        }
        
        let score = ((r * 255 * 299) + (g * 255 * 587) + (b * 255 * 114)) / 1000
        
        return score >= 175
    }
}

/// Remove objects from an array by value from http://stackoverflow.com/a/30724543
extension Array where Element : Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.firstIndex(of: object) {
            self.remove(at: index)
        }
    }
}

/// Random number generation from https://gist.github.com/JadenGeller/407036af08a28513eef2
struct Random {
    static func within(_ range: ClosedRange<Int>) -> Int {
        return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound + 1))) + range.lowerBound
    }
    
    static func within(_ range: ClosedRange<Float>) -> Float {
        return (range.upperBound - range.lowerBound) * Float(Float(arc4random()) / Float(UInt32.max)) + range.lowerBound
    }
    
    static func within(_ range: ClosedRange<Double>) -> Double {
        return (range.upperBound - range.lowerBound) * Double(Double(arc4random()) / Double(UInt32.max)) + range.lowerBound
    }
    
    static func generate() -> Int {
        return Random.within(0...1)
    }
    
    static func generate() -> Bool {
        return Random.generate() == 0
    }
    
    static func generate() -> Float {
        return Random.within(0.0...1.0)
    }
    
    static func generate() -> Double {
        return Random.within(0.0...1.0)
    }
}

// MARK: String/Key Conversion Utilities
/// Given a key/value pair as strings, add or modify the corresponding property
/// on an `Instrument` object.
///
/// - Parameter inst: the instrument to modify (passed by reference)
/// - Parameter propertyString: the property to modify, as a string from VWX
/// - Parameter propertyValue: the value to set the property to
func addPropertyToInstrument(_ inst: inout Instrument, propertyString: String, propertyValue: String) throws {
    
    func stringToDeviceType(_ devType: String) -> DeviceType {
        switch devType {
        case "Light": return .light
        case "Moving Light": return .movingLight
        case "Accessory": return .accessory
        case "Static Accessory": return .staticAccessory
        case "Device": return .device
        case "Practical": return .practical
        case "SFX": return .sfx
        case "Power": return .power
        default: return .other
        }
    }
    
    // throw out any of Vectorworks' hyphens
    if propertyValue == "-" {
        return
    }
    
    switch propertyString {
    case "Device Type": inst.deviceType = stringToDeviceType(propertyValue)
    case "Inst Type": inst.instrumentType = propertyValue
    case "Instrument Type": inst.instrumentType = propertyValue
    case "Wattage": inst.wattage = propertyValue
    case "Purpose": inst.purpose = propertyValue
    case "Position": inst.position = propertyValue
    case "Unit Number": inst.unitNumber = propertyValue
    case "Color": inst.color = propertyValue
    case "Dimmer": inst.dimmer = propertyValue
    case "Channel": inst.channel = propertyValue
    case "Address": inst.address = propertyValue
    case "Universe": inst.universe = propertyValue
    case "U Address": inst.uAddress = propertyValue
    case "U Dimmer": inst.uDimmer = propertyValue
    case "Circuit Number": inst.circuitNumber = propertyValue
    case "Circuit Name": inst.circuitName = propertyValue
    case "System": inst.system = propertyValue
    case "User Field 1": inst.userField1 = propertyValue
    case "User Field 2": inst.userField2 = propertyValue
    case "User Field 3": inst.userField3 = propertyValue
    case "User Field 4": inst.userField4 = propertyValue
    case "User Field 5": inst.userField5 = propertyValue
    case "User Field 6": inst.userField6 = propertyValue
    case "Num Channels": inst.numChannels = propertyValue
    case "Frame Size": inst.frameSize = propertyValue
    case "Field Angle": inst.fieldAngle = propertyValue
    case "Field Angle 2": inst.fieldAngle2 = propertyValue
    case "Beam Angle": inst.beamAngle = propertyValue
    case "Beam Angle 2": inst.beamAngle2 = propertyValue
    case "Weight": inst.weight = propertyValue
    case "Gobo 1": inst.gobo1 = propertyValue
    case "Gobo 1 Rotation": inst.gobo1Rotation = propertyValue
    case "Gobo 2": inst.gobo2 = propertyValue
    case "Gobo 2 Rotation": inst.gobo2Rotation = propertyValue
    case "Gobo Shift": inst.goboShift = propertyValue
    case "Mark": inst.mark = propertyValue
    case "Draw Beam": inst.drawBeam = (propertyValue.lowercased() == "true")
    case "Draw Beam as 3D Solid": inst.drawBeamAs3DSolid = (propertyValue.lowercased() == "true")
    case "Use Vertical Beam": inst.useVerticalBeam = (propertyValue.lowercased() == "true")
    case "Show Beam at": inst.showBeamAt = propertyValue
    case "Falloff Distance": inst.falloffDistance = propertyValue
    case "Lamp Rotation Angle": inst.lampRotationAngle = propertyValue
    case "Top Shutter Depth": inst.topShutterDepth = propertyValue
    case "Top Shutter Angle": inst.topShutterAngle = propertyValue
    case "Left Shutter Depth": inst.leftShutterDepth = propertyValue
    case "Left Shutter Angle": inst.leftShutterAngle = propertyValue
    case "Right Shutter Depth": inst.rightShutterDepth = propertyValue
    case "Right Shutter Angle": inst.rightShutterAngle = propertyValue
    case "Bottom Shutter Depth": inst.bottomShutterDepth = propertyValue
    case "Bottom Shutter Angle": inst.bottomShutterAngle = propertyValue
    case "Symbol Name": inst.symbolName = propertyValue
    case "Use Legend": inst.useLegend = (propertyValue.lowercased() == "true")
    case "Flip Front && Back Legend Text": inst.flipFrontBackLegendText = (propertyValue.lowercased() == "true")
    case "Flip Left && Right Legend Text": inst.flipLeftRightLegendText = (propertyValue.lowercased() == "true")
    case "Focus": inst.focus = propertyValue
    case "Set 3D Orientation": inst.set3DOrientation = (propertyValue.lowercased() == "true")
    case "X Rotation": inst.xRotation = propertyValue
    case "Y Rotation": inst.yRotation = propertyValue
    case "X Location":
        do {
            inst.rawXLocation = propertyValue
            try inst.addCoordinateToInitialLocation(.x, value: propertyValue)
        } catch {
            throw InstrumentError.ambiguousLocation
        }
    case "Y Location":
        do {
            inst.rawYLocation = propertyValue
            try inst.addCoordinateToInitialLocation(.y, value: propertyValue)
        } catch {
            throw InstrumentError.ambiguousLocation
        }
    case "Z Location":
        do {
            inst.rawZLocation = propertyValue
            try inst.addCoordinateToInitialLocation(.z, value: propertyValue)
        } catch {
            throw InstrumentError.ambiguousLocation
        }
    case "FixtureID": inst.fixtureID = propertyValue
    case "__UID": inst.UID = propertyValue
    case "Accessories": inst.accessories = propertyValue
    default: throw InstrumentError.propertyStringUnrecognized
    }
}

/// Given a VWX property string, find the corresponding property on an `Instrument`
/// object and return its value.
///
/// - Parameter inst: the instrument to modify (passed by reference)
/// - Parameter propertyString: the property to return, as a string from VWX
/// - Returns: the value of the requested property, or nil
func getPropertyFromInstrument(_ inst: Instrument, propertyString: String) throws -> String? {
    
    switch propertyString {
    case "Device Type": return inst.deviceType?.description
    case "Inst Type": return inst.instrumentType
    case "Instrument Type": return inst.instrumentType
    case "Wattage": return inst.wattage
    case "Purpose": return inst.purpose
    case "Position": return inst.position
    case "Unit Number": return inst.unitNumber
    case "Color": return inst.color
    case "Dimmer": return inst.dimmer
    case "Channel": return inst.channel
    case "Address": return inst.address
    case "Universe": return inst.universe
    case "U Address": return inst.uAddress
    case "U Dimmer": return inst.uDimmer
    case "Circuit Number": return inst.circuitNumber
    case "Circuit Name": return inst.circuitName
    case "System": return inst.system
    case "User Field 1": return inst.userField1
    case "User Field 2": return inst.userField2
    case "User Field 3": return inst.userField3
    case "User Field 4": return inst.userField4
    case "User Field 5": return inst.userField5
    case "User Field 6": return inst.userField6
    case "Num Channels": return inst.numChannels
    case "Frame Size": return inst.frameSize
    case "Field Angle": return inst.fieldAngle
    case "Field Angle 2": return inst.fieldAngle2
    case "Beam Angle": return inst.beamAngle
    case "Beam Angle 2": return inst.beamAngle2
    case "Weight": return inst.weight
    case "Gobo 1": return inst.gobo1
    case "Gobo 1 Rotation": return inst.gobo1Rotation
    case "Gobo 2": return inst.gobo2
    case "Gobo 2 Rotation": return inst.gobo2Rotation
    case "Gobo Shift": return inst.goboShift
    case "Mark": return inst.mark
    case "Draw Beam": return (inst.drawBeam == true) ? "True" : "False"
    case "Draw Beam as 3D Solid": return (inst.drawBeamAs3DSolid == true) ? "True" : "False"
    case "Use Vertical Beam": return (inst.useVerticalBeam == true) ? "True" : "False"
    case "Show Beam at": return inst.showBeamAt
    case "Falloff Distance": return inst.falloffDistance
    case "Lamp Rotation Angle": return inst.lampRotationAngle
    case "Top Shutter Depth": return inst.topShutterDepth
    case "Top Shutter Angle": return inst.topShutterAngle
    case "Left Shutter Depth": return inst.leftShutterDepth
    case "Left Shutter Angle": return inst.leftShutterAngle
    case "Right Shutter Depth": return inst.rightShutterDepth
    case "Right Shutter Angle": return inst.rightShutterAngle
    case "Bottom Shutter Depth": return inst.bottomShutterDepth
    case "Bottom Shutter Angle": return inst.bottomShutterAngle
    case "Symbol Name": return inst.symbolName
    case "Use Legend": return (inst.useLegend == true) ? "True" : "False"
    case "Flip Front && Back Legend Text": return (inst.flipFrontBackLegendText == true) ? "True" : "False"
    case "Flip Left && Right Legend Text": return (inst.flipLeftRightLegendText == true) ? "True" : "False"
    case "Focus": return inst.focus
    case "Set 3D Orientation": return (inst.set3DOrientation == true) ? "True" : "False"
    case "X Rotation": return inst.xRotation
    case "Y Rotation": return inst.yRotation
    case "X Location": return inst.rawXLocation
    case "Y Location": return inst.rawYLocation
    case "Z Location": return inst.rawZLocation
    case "FixtureID": return inst.fixtureID
    case "__UID": return inst.UID
    case "Accessories": return inst.accessories
    default: throw InstrumentError.propertyStringUnrecognized
    }
}

func connect(light: Instrument, dimmers: [Instrument]) {
    var shortestDistance: Double?
    
    if dimmers.filter({ $0.dimmer == light.dimmer }).count == 0 {
        light.receptacle = nil
        return
    }
    
    for dimmer in dimmers.filter({ $0.dimmer == light.dimmer }) {
        if shortestDistance == nil {
            do {
                shortestDistance = try HungarianMatrix.distanceBetween(light: light, dimmer: dimmer, cutCorners: Preferences.cutCorners)
                light.receptacle = dimmer
                dimmer.light = light
            } catch {
                shortestDistance = nil
            }
        } else {
            do {
                let tempDistance = try HungarianMatrix.distanceBetween(light: light, dimmer: dimmer, cutCorners: Preferences.cutCorners)
                if tempDistance < (shortestDistance ?? Double.greatestFiniteMagnitude) {
                    shortestDistance = tempDistance
                    light.receptacle = dimmer
                    dimmer.light = light
                }
            } catch {
                continue
            }
        }
    }
}

