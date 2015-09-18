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
        
        for char in self.characters {
            if char == "'" || char == "’" || char == "‘" {    // feet
                if exponent != "" {
                    guard let n1 = Float(numerator), let e1 = Float(exponent) else {
                        throw LengthFormatterError.StringToNumber
                    }
                    feet += Double(n1 * powf(10, e1))
                } else if denominator == "" {
                    guard let n1 = Double(numerator) else {
                        throw LengthFormatterError.StringToNumber
                    }
                    feet += n1
                } else {
                    guard let n1 = Double(numerator), let d1 = Double(denominator) else {
                        throw LengthFormatterError.StringToNumber
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
                        throw LengthFormatterError.StringToNumber
                    }
                    inches += Double(n1 * powf(10, e1))
                } else if denominator == "" {
                    guard let n1 = Double(numerator) else {
                        throw LengthFormatterError.StringToNumber
                    }
                    inches += n1
                } else {
                    guard let n1 = Double(numerator), let d1 = Double(denominator) else {
                        throw LengthFormatterError.StringToNumber
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
                    throw LengthFormatterError.FractionalFormattingError
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
                        throw LengthFormatterError.StringToNumber
                    }
                    inches += n1
                    numerator = ""
                }
            } else if char == "," {
                continue
            } else {
                throw LengthFormatterError.UnexpectedCharacter
            }
        }
        return (kMetersInFoot * feet) + (kMetersInInch * inches)
    }
    
    /// converts an string of known units to meters
    /// - Parameter metersInUnit: the number of meters per unit
    /// - Returns: the converted length in meters.
    func unitToMeter(metersInUnit: Double) throws -> Double {
        var units: Double = 0.0
        var numerator: String = ""
        var denominator: String = ""
        var exponent: String = ""
        var fillDenom = false
        var fillExponent = false
        
        for char in self.characters {
            if char == "e" { // power
                fillExponent = true
            } else if char == "/" { // fractional feet or inches
                guard fillDenom == false else {
                    throw LengthFormatterError.FractionalFormattingError
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
                        throw LengthFormatterError.StringToNumber
                    }
                    units += n1
                    numerator = ""
                }
            } else if char == "," {
                continue
            } else {
                throw LengthFormatterError.UnexpectedCharacter
            }
        }
        
        if exponent != "" {
            guard let n1 = Float(numerator), let e1 = Float(exponent) else {
                throw LengthFormatterError.StringToNumber
            }
            units += Double(n1 * powf(10, e1))
        } else if denominator == "" {
            guard let n1 = Double(numerator) else {
                throw LengthFormatterError.StringToNumber
            }
            units += n1
        } else {
            guard let n1 = Double(numerator), let d1 = Double(denominator) else {
                throw LengthFormatterError.StringToNumber
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
            if (self.rangeOfString("'") != nil || self.rangeOfString("’") != nil || self.rangeOfString("‘") != nil) &&
               (self.rangeOfString("\"") != nil || self.rangeOfString("“") != nil || self.rangeOfString("”") != nil) {
                return try self.feetAndInchesToMeters()
            } else if (self.rangeOfString("'") != nil || self.rangeOfString("’") != nil || self.rangeOfString("‘") != nil) {
                let replacementString = self.stringByReplacingOccurrencesOfString("'", withString: "").stringByReplacingOccurrencesOfString("’", withString: "").stringByReplacingOccurrencesOfString("‘", withString: "")
                return try replacementString.unitToMeter(kMetersInFoot)
            } else if (self.rangeOfString("\"") != nil || self.rangeOfString("“") != nil || self.rangeOfString("”") != nil) {
                let replacementString = self.stringByReplacingOccurrencesOfString("\"", withString: "").stringByReplacingOccurrencesOfString("“", withString: "").stringByReplacingOccurrencesOfString("”", withString: "")
                return try replacementString.unitToMeter(kMetersInInch)
            } else if self.rangeOfString("yd") != nil {
                return try self.stringByReplacingOccurrencesOfString("yd", withString: "").unitToMeter(kMetersInYard)
            } else if self.rangeOfString("mi") != nil {
                return try self.stringByReplacingOccurrencesOfString("mi", withString: "").unitToMeter(kMetersInMile)
            } else if self.rangeOfString("µm") != nil {
                return try self.stringByReplacingOccurrencesOfString("µm", withString: "").unitToMeter(kMetersInMicron)
            } else if self.rangeOfString("mm") != nil {
                return try self.stringByReplacingOccurrencesOfString("mm", withString: "").unitToMeter(kMetersInMillimeter)
            } else if self.rangeOfString("cm") != nil {
                return try self.stringByReplacingOccurrencesOfString("cm", withString: "").unitToMeter(kMetersInCentimeter)
            } else if self.rangeOfString("km") != nil {
                return try self.stringByReplacingOccurrencesOfString("km", withString: "").unitToMeter(kMetersInKilometer)
            } else if self.rangeOfString("m") != nil {
                return try self.stringByReplacingOccurrencesOfString("m", withString: "").unitToMeter(kMetersInMeter)
            } else if self.rangeOfString("°") != nil {
                return try self.stringByReplacingOccurrencesOfString("°", withString: "").unitToMeter(kMetersInDegrees)
            } else {
                // try to grab the preferred unit from preferences. If unavailable, just assume/pretend it's meters.
                switch (Preferences.preferredUnits) {
                    case .Feet: return try self.unitToMeter(kMetersInFoot)
                    case .Inches: return try self.unitToMeter(kMetersInInch)
                    case .Yards: return try self.unitToMeter(kMetersInYard)
                    case .Miles: return try self.unitToMeter(kMetersInMile)
                    case .Microns: return try self.unitToMeter(kMetersInMicron)
                    case .Millimeters: return try self.unitToMeter(kMetersInMillimeter)
                    case .Centimeters: return try self.unitToMeter(kMetersInCentimeter)
                    case .Kilometers: return try self.unitToMeter(kMetersInKilometer)
                    case .Custom: return try self.unitToMeter(Preferences.customUnitMeterConversion)
                    default: return try self.unitToMeter(kMetersInMeter)
                }
            }
        } catch LengthFormatterError.UnexpectedCharacter {
            throw LengthFormatterError.UnexpectedCharacter
        } catch LengthFormatterError.StringToNumber {
            throw LengthFormatterError.StringToNumber
        } catch LengthFormatterError.FractionalFormattingError {
            throw LengthFormatterError.FractionalFormattingError
        }
        
    }
}
