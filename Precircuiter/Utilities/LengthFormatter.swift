//
//  LengthFormatter.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/21/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Darwin

extension String {
    /// Converts a string in Vectorworks' "Feet and Inches" format to meters.
    /// - Returns: the value converted to meters
    func feetAndInchesToMeters() throws -> Double {
        var feet: Double = 0.0
        var inches: Double = 0.0
        var numerator: String = ""
        var denominator: String = ""
        var exponent: String = ""
        var fillDenom = false
        var fillExponent = false
        
        for char in self {
            if char == "'" || char == "’" || char == "‘" {    // feet
                if exponent != "" {
                    guard let n1 = Float(numerator), let e1 = Float(exponent) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    feet += Double(n1 * powf(10, e1))
                } else if denominator == "" {
                    guard let n1 = Double(numerator) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    feet += n1
                } else {
                    guard let n1 = Double(numerator), let d1 = Double(denominator) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    feet += n1 / d1
                }
                exponent = ""
                numerator = ""
                denominator = ""
                fillDenom = false
            } else if char == "\"" || char == "“" || char == "”" {  // inches
                if exponent != "" {
                    guard let n1 = Float(numerator), let e1 = Float(exponent) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    inches += Double(n1 * powf(10, e1))
                } else if denominator == "" {
                    guard let n1 = Double(numerator) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    inches += n1
                } else {
                    guard let n1 = Double(numerator), let d1 = Double(denominator) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    inches += n1 / d1
                }
                exponent = ""
                numerator = ""
                denominator = ""
                fillDenom = false
            } else if char == "e" { // power
                fillExponent = true
            } else if char == "/" { // fractional feet or inches
                guard fillDenom == false else {
                    throw LengthFormatterError.fractionalFormattingError
                }
                fillDenom = true
            } else if char >= "0" && char <= "9" || char == "." || char == "-" {   // number
                if fillExponent {
                    exponent.append(char)
                }else if fillDenom {
                    denominator.append(char)
                } else {
                    numerator.append(char)
                }
            } else if char == " " { // space - either separator after apostrophe or improper fraction
                if numerator == "" && denominator == "" {
                    continue
                } else {
                    guard let n1 = Double(numerator) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    inches += n1
                    numerator = ""
                }
            } else if char == "," {
                continue
            } else {
                throw LengthFormatterError.unexpectedCharacter
            }
        }
        return (kMetersInFoot * feet) + (kMetersInInch * inches)
    }
    
    /// converts an string of known units to meters
    /// - Parameter metersInUnit: the number of meters per unit
    /// - Returns: the converted length in meters.
    func unitToMeter(_ metersInUnit: Double) throws -> Double {
        var units: Double = 0.0
        var numerator: String = ""
        var denominator: String = ""
        var exponent: String = ""
        var fillDenom = false
        var fillExponent = false
        
        for char in self {
            if char == "e" { // power
                fillExponent = true
            } else if char == "/" { // fractional feet or inches
                guard fillDenom == false else {
                    throw LengthFormatterError.fractionalFormattingError
                }
                fillDenom = true
            } else if char >= "0" && char <= "9" || char == "." || char == "-" {   // number
                if fillExponent {
                    exponent.append(char)
                }else if fillDenom {
                    denominator.append(char)
                } else {
                    numerator.append(char)
                }
            } else if char == " " { // space - either separator after apostrophe or improper fraction
                if numerator == "" && denominator == "" {
                    continue
                } else {
                    guard let n1 = Double(numerator) else {
                        throw LengthFormatterError.stringToNumber
                    }
                    units += n1
                    numerator = ""
                }
            } else if char == "," {
                continue
            } else {
                throw LengthFormatterError.unexpectedCharacter
            }
        }
        
        if exponent != "" {
            guard let n1 = Float(numerator), let e1 = Float(exponent) else {
                throw LengthFormatterError.stringToNumber
            }
            units += Double(n1 * powf(10, e1))
        } else if denominator == "" {
            guard let n1 = Double(numerator) else {
                throw LengthFormatterError.stringToNumber
            }
            units += n1
        } else {
            guard let n1 = Double(numerator), let d1 = Double(denominator) else {
                throw LengthFormatterError.stringToNumber
            }
            units += n1 / d1
        }
        
        return units * metersInUnit
    }
    
    /// takes a string of arbitrary unit, and converts it to meters based on its
    /// unit label. If unit label is not present, fallback to user preferences.
    /// If those are unavailable, assume the string is already in meters.
    /// - Returns: the (possibly converted) length in meters
    func unknownUnitToMeters() throws -> Double {
        
        // Determine the case
        do {
            if (self.range(of: "'") != nil || self.range(of: "’") != nil || self.range(of: "‘") != nil) &&
               (self.range(of: "\"") != nil || self.range(of: "“") != nil || self.range(of: "”") != nil) {
                return try self.feetAndInchesToMeters()
            } else if (self.range(of: "'") != nil || self.range(of: "’") != nil || self.range(of: "‘") != nil) {
                let replacementString = self.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "’", with: "").replacingOccurrences(of: "‘", with: "")
                return try replacementString.unitToMeter(kMetersInFoot)
            } else if (self.range(of: "\"") != nil || self.range(of: "“") != nil || self.range(of: "”") != nil) {
                let replacementString = self.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "“", with: "").replacingOccurrences(of: "”", with: "")
                return try replacementString.unitToMeter(kMetersInInch)
            } else if self.range(of: "yd") != nil {
                return try self.replacingOccurrences(of: "yd", with: "").unitToMeter(kMetersInYard)
            } else if self.range(of: "mi") != nil {
                return try self.replacingOccurrences(of: "mi", with: "").unitToMeter(kMetersInMile)
            } else if self.range(of: "µm") != nil {
                return try self.replacingOccurrences(of: "µm", with: "").unitToMeter(kMetersInMicron)
            } else if self.range(of: "mm") != nil {
                return try self.replacingOccurrences(of: "mm", with: "").unitToMeter(kMetersInMillimeter)
            } else if self.range(of: "cm") != nil {
                return try self.replacingOccurrences(of: "cm", with: "").unitToMeter(kMetersInCentimeter)
            } else if self.range(of: "km") != nil {
                return try self.replacingOccurrences(of: "km", with: "").unitToMeter(kMetersInKilometer)
            } else if self.range(of: "m") != nil {
                return try self.replacingOccurrences(of: "m", with: "").unitToMeter(kMetersInMeter)
            } else if self.range(of: "°") != nil {
                return try self.replacingOccurrences(of: "°", with: "").unitToMeter(kMetersInDegrees)
            } else {
                // try to grab the preferred unit from preferences. If unavailable, just assume/pretend it's meters.
                switch (Preferences.preferredUnits) {
                    case .feet: return try self.unitToMeter(kMetersInFoot)
                    case .inches: return try self.unitToMeter(kMetersInInch)
                    case .yards: return try self.unitToMeter(kMetersInYard)
                    case .miles: return try self.unitToMeter(kMetersInMile)
                    case .microns: return try self.unitToMeter(kMetersInMicron)
                    case .millimeters: return try self.unitToMeter(kMetersInMillimeter)
                    case .centimeters: return try self.unitToMeter(kMetersInCentimeter)
                    case .kilometers: return try self.unitToMeter(kMetersInKilometer)
                    case .custom: return try self.unitToMeter(Preferences.customUnitMeterConversion)
                    default: return try self.unitToMeter(kMetersInMeter)
                }
            }
        } catch LengthFormatterError.unexpectedCharacter {
            throw LengthFormatterError.unexpectedCharacter
        } catch LengthFormatterError.stringToNumber {
            throw LengthFormatterError.stringToNumber
        } catch LengthFormatterError.fractionalFormattingError {
            throw LengthFormatterError.fractionalFormattingError
        }
        
    }
}
