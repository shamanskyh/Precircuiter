//
//  AssignUserEducationView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/9/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class AssignUserEducationView: NSView {
    
    @IBOutlet weak var plotView: PlotView!
    @IBOutlet weak var click1: ClickCircleUserEducationView!
    
    func setupPlotView() {
        plotView.delegate = self
        plotView.invalidateSymbolsAndRedraw()
        plotView.dimmerViews.forEach({ $0.isHidden = false })
        plotView.lightViews.forEach({ $0.isHidden = false })
        plotView.connectionViews.forEach({ $0.isHidden = false })
    }
    
    func animate() {

        // click 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.click1.animateInAndOut()
        }

        // animate connections
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.plotView.animateInConnections()
        }
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    // MARK: - Static Lights and Dimmers to draw
    let light1 = Instrument(UID: "Light1", location: [Coordinate(xPos: 1.0, yPos: 3.0, zPos: 0.0)])
    let light11 = Instrument(UID: "Light11", location: [Coordinate(xPos: 2.0, yPos: 3.0, zPos: 0.0)])
    let light2 = Instrument(UID: "Light2", location: [Coordinate(xPos: 6.0, yPos: 3.0, zPos: 0.0)])
    let light12 = Instrument(UID: "Light12", location: [Coordinate(xPos: 7.0, yPos: 3.0, zPos: 0.0)])
    let light3 = Instrument(UID: "Light3", location: [Coordinate(xPos: 11.0, yPos: 3.0, zPos: 0.0)])
    let light13 = Instrument(UID: "Light13", location: [Coordinate(xPos: 12.0, yPos: 3.0, zPos: 0.0)])
    
    let dimmer20 = Instrument(UID: "Dimmer20", location: [Coordinate(xPos: 3.0, yPos: 7.0, zPos: 0.0)])
    let dimmer21 = Instrument(UID: "Dimmer21", location: [Coordinate(xPos: 5.0, yPos: 5.0, zPos: 0.0)])
    let dimmer22 = Instrument(UID: "Dimmer22", location: [Coordinate(xPos: 8.0, yPos: 7.0, zPos: 0.0)])
    let dimmer23 = Instrument(UID: "Dimmer23", location: [Coordinate(xPos: 11.0, yPos: 5.0, zPos: 0.0)])
    let dimmer24 = Instrument(UID: "Dimmer24", location: [Coordinate(xPos: 3.0, yPos: 0.0, zPos: 0.0)])
    let dimmer25 = Instrument(UID: "Dimmer25", location: [Coordinate(xPos: 5.0, yPos: 0.0, zPos: 0.0)])
}

extension AssignUserEducationView: PlotViewDelegate {
    
    func getLights() -> [Instrument] {
        
        light1.channel = "1"
        light1.color = "R02"
        light1.receptacle = dimmer20
        
        light11.channel = "11"
        light11.color = "R60"
        light11.receptacle = dimmer24
        
        light2.channel = "2"
        light2.color = "R02"
        light2.receptacle = dimmer21
        
        light12.channel = "12"
        light12.color = "R60"
        light12.receptacle = dimmer25
        
        light3.channel = "3"
        light3.color = "R02"
        light3.receptacle = dimmer22
        
        light13.channel = "13"
        light13.color = "R60"
        light13.receptacle = dimmer23
        
        let lights: [Instrument] = [light1, light11, light2, light12, light3, light13]
        lights.forEach({ $0.deviceType = .light })
        return lights
    }
    
    func getDimmers() -> [Instrument] {
        
        dimmer20.dimmer = "20"
        dimmer20.light = light1
        
        dimmer21.dimmer = "21"
        dimmer21.light = light2
        
        dimmer22.dimmer = "22"
        dimmer22.light = light3
        
        dimmer23.dimmer = "23"
        dimmer23.light = light13
        
        dimmer24.dimmer = "24"
        dimmer24.light = light11
        
        dimmer25.dimmer = "25"
        dimmer24.light = light12
        
        let dimmers = [dimmer20, dimmer21, dimmer22, dimmer23, dimmer24, dimmer25]
        dimmers.forEach({ $0.deviceType = .power })
        return dimmers
    }
    
    func update(selectedDimmers: [Instrument], selectLights: Bool) {
        NSLog("Function is unimplemented in the demo version")
        return
    }
    
    func update(selectedLights: [Instrument], selectDimmers: Bool) {
        NSLog("Function is unimplemented in the demo version")
        return
    }
}
