//
//  DimmerSymbolView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/12/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

protocol DimmerSymbolDelegate {
    func updateDimmerSelection(sender: DimmerSymbolView)
}

class DimmerSymbolView: NSView {

    weak var dimmerInstrument: Instrument?
    var dimmer: String?
    var delegate: DimmerSymbolDelegate?
    var selected: Bool = false
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        NSColor.whiteColor().setFill()
        NSRectFill(dirtyRect)
        
        NSColor.lightGrayColor().setFill()
        NSBezierPath.setDefaultLineWidth(kDimmerStrokeWidth)
        NSFrameRect(dirtyRect)
        
        if let d = dimmer {
            
            let font = NSFont.systemFontOfSize(kDefaultDimmerFontSize)
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = NSTextAlignment.Center
            
            let color = NSColor.darkGrayColor()
            
            (d as NSString).drawInRect(dirtyRect.offsetBy(dx: 0.0, dy: 1.0), withAttributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: pStyle, NSForegroundColorAttributeName: color])
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        selected = true
        delegate?.updateDimmerSelection(self)
    }
}
