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
        DispatchQueue.main.after(when: .now() + 0.5) { [weak self] in
            self?.click1.animateInAndOut()
        }
        
        // click 2
        DispatchQueue.main.after(when: .now() + 2.0) { [weak self] in
            self?.click2.animateInAndOut()
        }
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
