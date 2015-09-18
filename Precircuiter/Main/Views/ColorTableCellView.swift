//
//  ColorTableCellView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/9/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class ColorTableCellView: NSTableCellView {

    @IBOutlet weak var swatchView: NSView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        if let color = (objectValue as! Instrument).swatchColor {
            color.setFill()
            NSBezierPath(ovalInRect: swatchView.frame).fill()
        }
    }
    
}
