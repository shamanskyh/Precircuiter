//
//  DimmerSymbolView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/12/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

protocol DimmerSymbolDelegate {
    func updateDimmerSelection(_ sender: DimmerSymbolView)
}

class DimmerSymbolView: NSView {

    weak var dimmerInstrument: Instrument?
    var dimmer: String?
    var delegate: DimmerSymbolDelegate?
    var selected: Bool = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.white.setFill()
        dirtyRect.fill()
        
        NSColor.lightGray.setFill()
        NSBezierPath.defaultLineWidth = kDimmerStrokeWidth
        dirtyRect.frame()
        
        if let d = dimmer {
            
            let font = NSFont.systemFont(ofSize: kDefaultDimmerFontSize)
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = NSTextAlignment.center
            
            let color = NSColor.darkGray
            
            (d as NSString).draw(in: dirtyRect.offsetBy(dx: 0.0, dy: 0.0), withAttributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: pStyle, NSAttributedString.Key.foregroundColor: color])
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        selected = true
        delegate?.updateDimmerSelection(self)
    }
}
