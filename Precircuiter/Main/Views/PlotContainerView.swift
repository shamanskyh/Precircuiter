//
//  PlotContainerView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/12/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

/// a simple outer view that acts as a container for the inner PlotView
/// where instruments are actually drawn
class PlotContainerView: NSView {

    @IBOutlet weak var innerView: PlotView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    override func awakeFromNib() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white().cgColor
    }
    
    // send clicks to the inner view
    override func mouseDown(_ theEvent: NSEvent) {
        innerView.mouseDown(theEvent)
    }
    
}
