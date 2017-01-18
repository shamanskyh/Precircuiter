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
    case quadrantI
    case quadrantII
    case quadrantIII
    case quadrantIV
}

class ConnectionView: NSView {

    init(light: Instrument, dimmer: Instrument) {
        self.light = light
        self.dimmer = dimmer
        super.init(frame: NSZeroRect)
    }

    required init?(coder: NSCoder) {
        // Note that these keys aren't actually in use yet
        self.light = coder.decodeObject(forKey: "light") as! Instrument
        self.dimmer = coder.decodeObject(forKey: "dimmer") as! Instrument
        super.init(coder: coder)
    }
    
    /// The dimmer that the ConnectionView is connecting
    var dimmer: Instrument {
        willSet {
            assert(newValue.deviceType == .power, "Dimmer must be of type .Power")
        }
    }
    
    /// The light that the ConnectionView is connecting
    var light: Instrument {
        willSet {
            assert(newValue.deviceType == .light || newValue.deviceType == .movingLight || newValue.deviceType == .practical, "Light must be of type .Light, .MovingLight, or .Practical")
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
            return .quadrantI
        } else if dimmerPoint.x >= lightPoint.x && dimmerPoint.y < lightPoint.y {
            return .quadrantIV
        } else if dimmerPoint.x < lightPoint.x && dimmerPoint.y >= lightPoint.y {
            return .quadrantII
        }
        return .quadrantIII
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
        case .quadrantI:
            x = lightPoint.x
            y = lightPoint.y
        case .quadrantII:
            x = dimmerPoint.x
            y = lightPoint.y
        case .quadrantIII:
            x = dimmerPoint.x
            y = dimmerPoint.y
        case .quadrantIV:
            x = lightPoint.x
            y = dimmerPoint.y
        }
        self.frame = CGRect(x: x, y: y, width: max(kConnectionStrokeWidth, width), height: max(kConnectionStrokeWidth, height))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSBezierPath.setDefaultLineWidth(kConnectionStrokeWidth)
        NSColor.darkGray.setStroke()
        let line = NSBezierPath()
        
        if Preferences.cutCorners {
            if relativePositioning == .quadrantI || relativePositioning == .quadrantIII {
                line.move(to: dirtyRect.origin)
                line.line(to: NSPoint(x: dirtyRect.maxX, y: dirtyRect.maxY))
            } else {
                line.move(to: NSPoint(x: dirtyRect.minX, y: dirtyRect.maxY))
                line.line(to: NSPoint(x: dirtyRect.maxX, y: dirtyRect.minY))
            }
        } else {
            let kConnectionViewInset: CGFloat = kDimmerStrokeWidth;
            if relativePositioning == .quadrantI || relativePositioning == .quadrantIII {
                if dirtyRect.width > dirtyRect.height {
                    line.move(to: NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.midY))
                    line.line(to: NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.midY))
                    line.line(to: NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                } else {
                    line.move(to: NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.midX, y: dirtyRect.minY + kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.midX, y: dirtyRect.maxY - kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                }
            } else {
                if dirtyRect.width > dirtyRect.height {
                    line.move(to: NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.midY))
                    line.line(to: NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.midY))
                    line.line(to: NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                } else {
                    line.move(to: NSPoint(x: dirtyRect.minX + kConnectionViewInset, y: dirtyRect.maxY - kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.midX, y: dirtyRect.maxY - kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.midX, y: dirtyRect.minY + kConnectionViewInset))
                    line.line(to: NSPoint(x: dirtyRect.maxX - kConnectionViewInset, y: dirtyRect.minY + kConnectionViewInset))
                }
            }
        }
        line.stroke()
    }
    
}
