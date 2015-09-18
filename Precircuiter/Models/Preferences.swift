//
//  Preferences.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/20/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Foundation

enum UnitType: Int {
    case FeetAndInches
    case Feet
    case Inches
    case Yards
    case Miles
    case Microns
    case Millimeters
    case Centimeters
    case Meters
    case Kilometers
    case Degrees
    case Custom
}

class Preferences {
    
    static var cutCorners: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kCutCornersPreferenceKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kShouldReloadPlotViewNotification, object: nil))
        } get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kCutCornersPreferenceKey)
        }
    }
    
    static var preferredUnits: UnitType {
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: kPreferredUnitsPreferenceKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        } get {
            return UnitType(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kPreferredUnitsPreferenceKey))!
        }
    }
    
    static var customUnitMeterConversion: Double {
        set {
            NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: kUnitsToMeterConversionPreferenceKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        } get {
            return NSUserDefaults.standardUserDefaults().doubleForKey(kUnitsToMeterConversionPreferenceKey)
        }
    }
    
    static var showConnections: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kShowConnectionsPreferenceKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kShouldReloadPlotViewNotification, object: nil))
        } get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kShowConnectionsPreferenceKey)
        }
    }
    
    static var animateConnections: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kAnimateConnectionsPreferenceKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kShouldReloadPlotViewNotification, object: nil))
        } get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kAnimateConnectionsPreferenceKey)
        }
    }
    
    static var stopShowingStartScreen: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kStopShowingStartScreenPreferenceKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        } get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kStopShowingStartScreenPreferenceKey)
        }
    }
}