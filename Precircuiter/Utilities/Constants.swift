//
//  Constants.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/20/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

// MARK: - Units of Measurement
let kMetersInFoot: Double       = 0.3048
let kMetersInInch: Double       = 0.0254
let kMetersInYard: Double       = 0.9144
let kMetersInMile: Double       = 1609.34
let kMetersInMicron: Double     = 0.000001
let kMetersInMillimeter: Double = 0.001
let kMetersInCentimeter: Double = 0.01
let kMetersInKilometer: Double  = 1000.0
let kMetersInMeter: Double      = 1.0
let kMetersInDegrees: Double    = 1.0

// MARK: - PlotView Drawing Constants
let kDefaultLightSymbolSize: CGSize     = CGSize(width: 26.0, height: 19.5)
let kDefaultDimmerSymbolSize: CGSize    = CGSize(width: 20.0, height: 12.0)
let kLightStrokeWidth: CGFloat          = 1.0
let kDimmerStrokeWidth: CGFloat         = 1.0
let kConnectionStrokeWidth: CGFloat     = 2.0
let kDefaultDimmerFontSize: CGFloat     = 9.0
let kDefaultLightFontSize: CGFloat      = 8.0

// MARK: - Unique Splitter Characters
let kUniqueSplitterCharacter: Character = "\u{0007}"  // ASCII Bell Character

// MARK: - Storyboard Identifiers
let kMainStoryboardIdentifier: String       = "Main"
let kMainDocumentWindowIdentifier: String   = "MainDocumentWindow"
let kStartScreenWindowIdentifier: String    = "StartScreenWindow"

// MARK: - Preferences Keys
let kShowConnectionsPreferenceKey: String           = "ShowConnections"
let kAnimateConnectionsPreferenceKey: String        = "AnimateConnections"
let kCutCornersPreferenceKey: String                = "CutCorners"
let kPreferredUnitsPreferenceKey: String            = "PreferredUnits"
let kUnitsToMeterConversionPreferenceKey: String    = "CustomUnitMeterConversion"
let kStopShowingStartScreenPreferenceKey: String    = "StopShowingStartScreen"

// MARK: - Notifications Keys
let kShouldReloadPlotViewNotification: String = "ShouldReloadPlotView"

// MARK: - PlotView Animation Durations
let kMinAnimationDelay: Double      = 0.0
let kMaxAnimationDelay: Double      = 0.2
let kMinAnimationDuration: Double   = 0.2
let kMaxAnimationDuration: Double   = 0.6

// MARK: - UserEducation Animations
let kClickCircleColor: NSColor  = NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
let kClickMaxAlpha: CGFloat     = 0.7
let kClickShowDuration: Double  = 0.5
let kClickHideDuration: Double  = 0.7
