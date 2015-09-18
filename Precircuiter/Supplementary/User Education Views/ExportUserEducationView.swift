//
//  ExportUserEducationView.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/9/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class ExportUserEducationView: NSView {
    
    @IBOutlet weak var click1: ClickCircleUserEducationView!
    @IBOutlet weak var click2: ClickCircleUserEducationView!
    
    func animate() {
        
        // click 1
        delay (0.5) {
            self.click1.animateInAndOut()
        }
        
        // click 2
        delay (2.0) {
            self.click2.animateInAndOut()
        }
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
