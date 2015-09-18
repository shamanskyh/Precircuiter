//
//  ConnectionView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/2/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

/// Relative position of dimmer to light
enum RelativePosition {
    case QuadrantI
    case QuadrantII
    case QuadrantIII
    case QuadrantIV
}

class ConnectionView: NSView {

    init(light: Instrument, dimmer: Instrument) {
        self.light = light
        self.dimmer = dimmer
        super.init(frame: NSZeroRect)
    }

    required init?(coder: NSCoder) {
        // Note that these keys aren't actually in use yet
        self.light = coder.decodeObjectForKey("light") as! Instrument
        self.dimmer = coder.decodeObjectForKey("dimmer") as! Instrument
        super.init(coder: coder)
    }
    
    /// The dimmer that the ConnectionView is connecting
    var dimmer: Instrument {
        willSet {
            assert(newValue.deviceType == .Power, "Dimmer must be of type .Power")
        }
    }
    
    /// The light that the ConnectionView is connecting
    var light: Instrument {
        willSet {
            assert(newValue.deviceType == .Light || newValue.deviceType == .MovingLight || newValue.deviceType == .Practical, "Light must be of type .Light, .MovingLight, or .Practical")
        }
    }
    
    /// The CGPoint representing the dimmer in the PlotView
    var dimmerPoint: CGPoint {
        return CGPoint(x: dimmer.viewRepresentation.frame.midX, y: dimmer.viewRepresentation.frame.midY)
    }
    
    /// The CGPoint representing the light in the PlotView
    var lightPoint: CGPoint {
        return CGPoint(x: light.viewRepresentation.frame.midX, y: light.viewRepresentation.frame.midY)
    }
    
    /// Returns the relative position of the dimmer to the light
    private var relativePositioning: RelativePosition {
        if dimmerPoint.x >= lightPoint.x && dimmerPoint.y >= lightPoint.y {
            return .QuadrantI
        } else if dimmerPoint.x >= lightPoint.x && dimmerPoint.y < lightPoint.y {
            return .QuadrantIV
        } else if dimmerPoint.x < lightPoint.x && dimmerPoint.y >= lightPoint.y {
            return .QuadrantII
        }
        return .QuadrantIII
    }
    
    /// Automatically sets the ConnectionView's frame to be in its pre-animation state
    func sizeToAnimate() {
        self.frame = CGRect(x: lightPoint.x, y: lightPoint.y, width: 0.0, height: 0.0)
    }
    
    /// Animate the ConnectionView's frame change
    func animateIn() {
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
            context.duration = Random.within(kMinAnimationDuration...kMaxAnimationDuration)
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            context.allowsImplicitAnimation = true
            self.sizeToConnect()
        }, completionHandler: nil)
    }
    
    /// Automatically sets the ConnectionView's frame based on its light and dimmer
    func sizeToConnect() {
        let width = abs(dimmerPoint.x - lightPoint.x)
        let height = abs(dimmerPoint.y - lightPoint.y)
        let x: CGFloat
        let y: CGFloat
        switch (self.relativePositioning) {
        case .QuadrantI:
            x = lightPoint.x
            y = lightPoint.y
        case .QuadrantII:
            x = dimmerPoint.x
            y = lightPoint.y
        case .QuadrantIII:
            x = dimmerPoint.x
            y = dimmerPoint.y
        case .QuadrantIV:
            x = lightPoint.x
            y = dimmerPoint.y
        }
        self.frame = CGRect(x: x, y: y, width: max(kConnectionStrokeWidth, width), height: max(kConnectionStrokeWidth, height))
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        NSBezierPath.setDefaultLineWidth(kConnectionStrokeWidth)
        NSColor.darkGrayColor().setStroke()
        let line = NSBezierPath()
        
        if Preferences.cutCorners {
            if relativePositioning == .QuadrantI || relativePositioning == .QuadrantIII {
                line.moveToPoint(dirtyRect.origin)
                line.lineToPoint(NSPoint(x: dirtyRect.maxX, y: dirtyRect.maxY))
            } else {
                line.moveToPoint(NSPoint(x: dirtyRect.minX, y: dirtyRect.maxY))
                line.lineToPoint(NSPoint(x: dirtyRect.maxX, y: dirtyRect.minY))
            }
        } else {
            let kConnectionViewInset: CGFloat = kDimmerStrokeWidth;
            if relativePositioning == .QuadrantI || relativePositioning == .QuadrantIII {
                if dirtyRect.width > dirtyRect.height {
                    line.moveToPoint(NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.midY))
                    line.lineToPoint(NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.midY))
                    line.lineToPoint(NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                } else {
                    line.moveToPoint(NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.midX, y: dirtyRect.minY + kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.midX, y: dirtyRect.maxY - kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                }
            } else {
                if dirtyRect.width > dirtyRect.height {
                    line.moveToPoint(NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.midY))
                    line.lineToPoint(NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.midY))
                    line.lineToPoint(NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                } else {
                    line.moveToPoint(NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.midX, y: dirtyRect.maxY - kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.midX, y: dirtyRect.minY + kConnectionViewInset))
                    line.lineToPoint(NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                }
            }
        }
        line.stroke()
    }
    
}
