//
//  PlotView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 8/19/14.
//  Copyright (c) 2014 Harry Shamansky. All rights reserved.
//

import Cocoa

protocol PlotViewDelegate {
    func getLights() -> [Instrument]
    func getDimmers() -> [Instrument]
    func update(selectedLights: [Instrument], selectDimmers: Bool)
    func update(selectedDimmers: [Instrument], selectLights: Bool)
}

/// The graphical representation of lights on the plot. Used to create zones,
/// to accomodate plots with distinct areas on the same plane.
class PlotView: NSView {
    
    var delegate: PlotViewDelegate?
    
    /// a filter property that determines what instruments are shown
    var filter: PlotViewFilterType = .lights {
        didSet {
            updateFilter()
        }
    }
    
    internal func updateFilter() {
        switch(filter) {
        case .lights:
            lightViews.forEach({ $0.isHidden = false })
            dimmerViews.forEach({ $0.isHidden = true })
            connectionViews.forEach({ $0.isHidden = true })
        case .dimmers:
            lightViews.forEach({ $0.isHidden = true })
            dimmerViews.forEach({ $0.isHidden = false })
            connectionViews.forEach({ $0.isHidden = true })
        case .both:
            lightViews.forEach({ $0.isHidden = false })
            dimmerViews.forEach({ $0.isHidden = false })
            connectionViews.forEach({ $0.isHidden = false })
        }
    }
    
    var connectionViews: [ConnectionView] = []
    var lightViews: [LightSymbolView] = []
    var dimmerViews: [DimmerSymbolView] = []
    
    /// determine whether the animation occurred
    var isAnimating: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // refresh the plot view if anything is undone/redone, or if the drawing preferences are updated
        NotificationCenter.default().addObserver(self, selector: #selector(PlotView.invalidateSymbolsAndRedraw), name: NSNotification.Name.NSUndoManagerDidUndoChange, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(PlotView.invalidateSymbolsAndRedraw), name: NSNotification.Name.NSUndoManagerDidRedoChange, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(PlotView.invalidateSymbolsAndRedraw), name: kShouldReloadPlotViewNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.NSUndoManagerDidUndoChange, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.NSUndoManagerDidRedoChange, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name(rawValue: kShouldReloadPlotViewNotification), object: nil)
    }
    
    var instrumentsToRender: [Instrument] {
        var returnInstruments: [Instrument] = []
        if let dimmers = delegate?.getDimmers() {
            returnInstruments += dimmers
        }
        if let lights = delegate?.getLights() {
            returnInstruments += lights
        }
        return returnInstruments
    }
    
    var instrumentsToIncludeInBoundingRect: [Instrument] {
        var returnInstruments: [Instrument] = []
        if let dimmers = delegate?.getDimmers() {
            returnInstruments += dimmers
        }
        if let lights = delegate?.getLights() {
            returnInstruments += lights
        }
        return returnInstruments
    }
    
    var boundingRect: CGRect {
        return self.getBoundingRectForInstruments(instrumentsToIncludeInBoundingRect)
    }
    
    func invalidateSymbolsAndRedraw() {
        
        subviews = []
        
        delegate?.getLights().forEach({ $0.needsNewViewRepresentation = true })
        delegate?.getLights().forEach({ $0.needsNewSwatchColor = true })
        delegate?.getDimmers().forEach({ $0.needsNewViewRepresentation = true })
        
        if let lightSymbolViews = delegate?.getLights().map({ $0.viewRepresentation }) {
            lightViews = lightSymbolViews as! [LightSymbolView]
        }
        if let dimmerSymbolViews = delegate?.getDimmers().map({ $0.viewRepresentation }) {
            dimmerViews = dimmerSymbolViews as! [DimmerSymbolView]
        }

        let views = prepareInstruments(instrumentsToRender, boundingRect: boundingRect)

        if let delegateLights = delegate?.getLights() where Preferences.showConnections {
            connectionViews = prepareConnections(delegateLights)
            subviews += connectionViews as [NSView]
        }

        subviews += views
        needsDisplay = true
        updateFilter()
    }
    
    /// Returns a rect that encompasses all instruments
    ///
    /// - Parameter instruments: an array of `Instrument` objects
    /// - Returns: A bounding rect for all instruments
    private func getBoundingRectForInstruments(_ instruments: [Instrument]) -> CGRect {
        guard let loc = instruments.first?.locations.first else {
            return CGRect.zero
        }
        var minX = loc.x
        var minY = loc.y
        var maxX = loc.x
        var maxY = loc.y
        
        for inst in instruments {
            guard let loc = inst.locations.first else {
                continue
            }
            if loc.x < minX {
                minX = loc.x
            }
            if loc.y < minY {
                minY = loc.y
            }
            if loc.x > maxX {
                maxX = loc.x
            }
            if loc.y > maxY {
                maxY = loc.y
            }
        }
        
        let width = max(maxX - minX, 0.001) // prevent 0 width
        let height = max(maxY - minY, 0.001) // prevent 0 height
        
        return CGRect(x: minX, y: minY, width: width, height: height)
    }
    
    /// resizes all the instrument views to fit within the bounding rect
    private func resizeInstrumentSymbols(_ lightSymbols: [LightSymbolView], dimmerSymbols: [DimmerSymbolView], boundingRect: CGRect) {
        let xOffset: Double = Double(-boundingRect.origin.x)
        let yOffset: Double = Double(-boundingRect.origin.y)
        
        for instrument in lightSymbols.map({ $0.lightInstrument }) + dimmerSymbols.map({ $0.dimmerInstrument }) {
            guard let inst = instrument, loc = inst.locations.first else {
                continue
            }
            
            // TODO: allow top/side/bottom views here
            let scaledX = (CGFloat(loc.x + xOffset) / boundingRect.width) * (self.frame.width - kDefaultLightSymbolSize.width)
            let scaledY = (CGFloat(loc.y + yOffset) / boundingRect.height) * (self.frame.height - kDefaultLightSymbolSize.height)
            
            // add delegates for mouseDown events
            if let lightSymbol = inst.viewRepresentation as? LightSymbolView {
                lightSymbol.delegate = self
            } else if let dimmerSymbol = inst.viewRepresentation as? DimmerSymbolView {
                dimmerSymbol.delegate = self
            }
            
            inst.viewRepresentation.toolTip = inst.description
            
            if inst.deviceType == .power {
                inst.setViewRepresentationFrame(CGRect(x: floor(scaledX), y: floor(scaledY), width: kDefaultDimmerSymbolSize.width, height: kDefaultDimmerSymbolSize.height))
            } else {
                inst.setViewRepresentationFrame(CGRect(x: floor(scaledX), y: floor(scaledY), width: kDefaultLightSymbolSize.width, height: kDefaultLightSymbolSize.height))
            }
        }
    }
    
    private func resizeConnectionViews(_ connectionViews: [ConnectionView]) {
        connectionViews.forEach({ $0.sizeToConnect() })
    }
    
    /// Draws the instruments in the region
    internal func prepareInstruments(_ instruments: [Instrument]?, boundingRect: CGRect) -> [NSView] {

        var returnViews: [NSView] = []
        
        guard let insts = instruments else {
            return []
        }
        
        let xOffset: Double = Double(-boundingRect.origin.x)
        let yOffset: Double = Double(-boundingRect.origin.y)
        
        for inst in insts {
            
            guard let loc = inst.locations.first else {
                continue
            }
            
            // TODO: allow top/side/bottom views here
            let scaledX = (CGFloat(loc.x + xOffset) / boundingRect.width) * (self.frame.width - kDefaultLightSymbolSize.width)
            let scaledY = (CGFloat(loc.y + yOffset) / boundingRect.height) * (self.frame.height - kDefaultLightSymbolSize.height)
            
            if inst.selected {
                returnViews.append(inst.viewRepresentation)
            } else {
                returnViews.insert(inst.viewRepresentation, at: 0)
            }
            
            // add delegates for mouseDown events
            if let lightSymbol = inst.viewRepresentation as? LightSymbolView {
                lightSymbol.delegate = self
            } else if let dimmerSymbol = inst.viewRepresentation as? DimmerSymbolView {
                dimmerSymbol.delegate = self
            }
            
            inst.viewRepresentation.toolTip = inst.description
            
            if inst.deviceType == .power {
                inst.setViewRepresentationFrame(CGRect(x: scaledX, y: scaledY, width: kDefaultDimmerSymbolSize.width, height: kDefaultDimmerSymbolSize.height))
            } else {
                inst.setViewRepresentationFrame(CGRect(x: scaledX, y: scaledY, width: kDefaultLightSymbolSize.width, height: kDefaultLightSymbolSize.height))
            }
            
        }
        
        return returnViews
    }
    
    internal func prepareConnections(_ instruments: [Instrument]) -> [ConnectionView] {
        var returnViews: [ConnectionView] = []
        for light in instruments where light.receptacle != nil {
            let connectionView = ConnectionView(light: light, dimmer: light.receptacle!)
            if Preferences.animateConnections {
                connectionView.sizeToAnimate()
            } else {
                connectionView.sizeToConnect()
            }
            returnViews.append(connectionView)
        }
        return returnViews
    }
    
    internal func animateInConnections() {
        isAnimating = true
        for connectionView in connectionViews {
            DispatchQueue.main.after(when: .now() + Random.within(kMinAnimationDelay...kMaxAnimationDelay)) {
                connectionView.animateIn()
            }
        }
        DispatchQueue.main.after(when: .now() + Double(kMaxAnimationDelay + kMaxAnimationDuration)) {
            self.isAnimating = false
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // resize the views here
        resizeInstrumentSymbols(lightViews, dimmerSymbols: dimmerViews, boundingRect: boundingRect)
        
        if isAnimating == false {
            resizeConnectionViews(connectionViews)
        }
    }
    
    override func mouseDown(_ theEvent: NSEvent) {
        delegate?.update(selectedLights: [], selectDimmers: false)
    }
}

extension PlotView: LightSymbolDelegate {
    func updateLightSelection(_ sender: LightSymbolView) {
        if let light = sender.lightInstrument {
            delegate?.update(selectedLights: [light], selectDimmers: true)
        }
    }
}

extension PlotView: DimmerSymbolDelegate {
    func updateDimmerSelection(_ sender: DimmerSymbolView) {
        if let dimmer = sender.dimmerInstrument {
            delegate?.update(selectedDimmers: [dimmer], selectLights: true)
        }
    }
}
