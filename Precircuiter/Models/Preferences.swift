//
//  Preferences.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/20/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Foundation

enum UnitType: Int {
    case feetAndInches
    case feet
    case inches
    case yards
    case miles
    case microns
    case millimeters
    case centimeters
    case meters
    case kilometers
    case degrees
    case custom
}

class Preferences {
    
    static var cutCorners: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kCutCornersPreferenceKey)
            NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: kShouldReloadPlotViewNotification), object: nil))
        } get {
            return UserDefaults.standard.bool(forKey: kCutCornersPreferenceKey)
        }
    }
    
    static var preferredUnits: UnitType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: kPreferredUnitsPreferenceKey)
        } get {
            return UnitType(rawValue: UserDefaults.standard.integer(forKey: kPreferredUnitsPreferenceKey))!
        }
    }
    
    static var customUnitMeterConversion: Double {
        set {
            UserDefaults.standard.set(newValue, forKey: kUnitsToMeterConversionPreferenceKey)
        } get {
            return UserDefaults.standard.double(forKey: kUnitsToMeterConversionPreferenceKey)
        }
    }
    
    static var showConnections: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kShowConnectionsPreferenceKey)
            NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: kShouldReloadPlotViewNotification), object: nil))
        } get {
            return UserDefaults.standard.bool(forKey: kShowConnectionsPreferenceKey)
        }
    }
    
    static var animateConnections: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kAnimateConnectionsPreferenceKey)
            NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: kShouldReloadPlotViewNotification), object: nil))
        } get {
            return UserDefaults.standard.bool(forKey: kAnimateConnectionsPreferenceKey)
        }
    }
    
    static var stopShowingStartScreen: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kStopShowingStartScreenPreferenceKey)
        } get {
            return UserDefaults.standard.bool(forKey: kStopShowingStartScreenPreferenceKey)
        }
    }
}
