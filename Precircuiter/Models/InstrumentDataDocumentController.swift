//
//  InstrumentDataDocumentController.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/6/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class InstrumentDataDocumentController: NSDocumentController {

    var count = 0
    
    override func runModalOpenPanel(_ openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
        openPanel.delegate = self
        return super.runModalOpenPanel(openPanel, forTypes: types)
    }
    
}

extension InstrumentDataDocumentController: NSOpenSavePanelDelegate {
    
    func panel(_ sender: AnyObject, shouldEnable url: URL) -> Bool {
        let fileExtension = url.pathExtension
        if fileExtension == "" || fileExtension == "txt" {
            return true
        }
        return false
    }
}
