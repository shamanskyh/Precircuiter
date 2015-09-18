//
//  ClickCircleUserEducationView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/11/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class ClickCircleUserEducationView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        kClickCircleColor.setFill()
        NSBezierPath(ovalInRect: dirtyRect).fill()
    }
    
    func animateInAndOut() {
        
        alphaValue = 0.0
        hidden = false
        let originalFrame = frame
        
        frame = NSRect(x: frame.midX, y: frame.midY, width: 0.0, height: 0.0)
        
        // show
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
            context.duration = kClickShowDuration
            self.animator().frame = originalFrame
            self.animator().alphaValue = kClickMaxAlpha
            }) {
                // hide
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
                    context.duration = kClickHideDuration
                    self.animator().alphaValue = 0.0
                    }, completionHandler: {
                        self.hidden = true
                        self.frame = originalFrame
                })
        }
    }
    
}
