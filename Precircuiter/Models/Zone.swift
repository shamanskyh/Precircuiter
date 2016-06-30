//
//  Zone.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/20/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class Zone: NSObject {
    var lights: [Instrument] = []
    var dimmers: [Instrument] = []
    var color: NSColor? = nil
    var region: NSRect = CGRect.zero
}
