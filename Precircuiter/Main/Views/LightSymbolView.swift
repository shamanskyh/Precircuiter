//
//  LightSymbolView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/12/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

protocol LightSymbolDelegate {
    func updateLightSelection(_ sender: LightSymbolView)
}

class LightSymbolView: NSView {

    weak var lightInstrument: Instrument?
    var channel: String?
    var color: NSColor?
    var selected: Bool = false
    var delegate: LightSymbolDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if selected {
            let selectedPath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 0.5, dy: 0.5))
            NSColor.controlAccentColor.setFill()
            selectedPath.fill()
        }
        
        NSColor.darkGray.setStroke()
        
        let circlePath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 2.5, dy: 2.5))
        circlePath.lineWidth = 1.0
        
        if let c = color {
            c.setFill()
            circlePath.fill()
        } else {
            NSColor.white.setFill()
            circlePath.fill()
            NSColor.lightGray.setStroke()
            circlePath.stroke()
        }
        
        if let c = channel {
            
            let font = NSFont.boldSystemFont(ofSize: kDefaultLightFontSize)
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = NSTextAlignment.center
            
            let textColor: NSColor
            if let lightColor = self.color {
                textColor = lightColor.isLight() ? NSColor.darkGray : NSColor.white
            } else {
                textColor = NSColor.lightGray
            }
            
            (c as NSString).draw(in: dirtyRect.offsetBy(dx: 0.0, dy: -4.5), withAttributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: pStyle, NSAttributedString.Key.foregroundColor: textColor])
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        selected = true
        delegate?.updateLightSelection(self)
    }
}
