//
//  LightSymbolView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/12/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

protocol LightSymbolDelegate {
    func updateLightSelection(sender: LightSymbolView)
}

class LightSymbolView: NSView {

    weak var lightInstrument: Instrument?
    var channel: String?
    var color: NSColor?
    var selected: Bool = false
    var delegate: LightSymbolDelegate?
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        if selected {
            let selectedPath = NSBezierPath(ovalInRect: dirtyRect.insetBy(dx: 0.5, dy: 0.5))
            selectedPath.lineWidth = 1.0
            
            NSColor.whiteColor().setFill()
            selectedPath.fill()
            
            NSColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).setStroke()
            selectedPath.stroke()
        }
        
        NSColor.darkGrayColor().setStroke()
        
        let circlePath = NSBezierPath(ovalInRect: dirtyRect.insetBy(dx: 2.5, dy: 2.5))
        circlePath.lineWidth = 1.0
        
        if let c = color {
            c.setFill()
            circlePath.fill()
        } else {
            NSColor.whiteColor().setFill()
            circlePath.fill()
            NSColor.lightGrayColor().setStroke()
            circlePath.stroke()
        }
        
        if let c = channel {
            
            let font = NSFont.boldSystemFontOfSize(kDefaultLightFontSize)
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = NSTextAlignment.Center
            
            let textColor: NSColor
            if let lightColor = self.color {
                textColor = lightColor.isLight() ? NSColor.darkGrayColor() : NSColor.whiteColor()
            } else {
                textColor = NSColor.lightGrayColor()
            }
            
            (c as NSString).drawInRect(dirtyRect.offsetBy(dx: 0.0, dy: -3.5), withAttributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: pStyle, NSForegroundColorAttributeName: textColor])
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        selected = true
        delegate?.updateLightSelection(self)
    }
}
