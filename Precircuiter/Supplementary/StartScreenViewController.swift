//
//  StartScreenViewController.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 9/8/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class StartScreenViewController: NSViewController {

    @IBOutlet weak var carouselTray: NSView!
    
    @IBOutlet weak var mainTitleLabel: NSTextField!
    @IBOutlet weak var showScreenCheckbox: NSButton!
    
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    
    @IBOutlet weak var carouselPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var exportUserEducationView: ExportUserEducationView!
    @IBOutlet weak var assignUserEducationView: AssignUserEducationView!
    @IBOutlet weak var importUserEducationView: ImportUserEducationView!
    
    let nextButtonSizeIncrease: CGFloat = 100.0
    
    var currentIndex: Int {
        let offset = -1 * carouselTray.frame.minX
        return Int(floor(offset / view.frame.width))
    }
    
    var isAnimatingCarousel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carouselTray.wantsLayer = true
        carouselTray.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        mainTitleLabel.alphaValue = 1.0
        showScreenCheckbox.alphaValue = 0.0
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.titlebarAppearsTransparent = true
        view.window?.movableByWindowBackground = true
    }
    
    override func viewDidAppear() {
        assignUserEducationView.setupPlotView()
        
        delay (1.0) {
            self.exportUserEducationView.animate()
        }
    }
    
    @IBAction func nextPressed(sender: AnyObject) {
        
        if isAnimatingCarousel {
            return
        }
        
        backButton.enabled = true
        
        switch (currentIndex) {
        case 0:
            isAnimatingCarousel = true
            assignUserEducationView.plotView.connectionViews.forEach({ $0.sizeToAnimate() })
            NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
                context.duration = 0.5
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.carouselPositionConstraint.animator().constant -= self.view.frame.width
                }, completionHandler: {
                    self.isAnimatingCarousel = false
                    self.assignUserEducationView.animate()
            })
        case 1:
            isAnimatingCarousel = true
            showScreenCheckbox.hidden = false
            NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
                context.duration = 0.5
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                context.allowsImplicitAnimation = true
                self.carouselPositionConstraint.animator().constant -= self.view.frame.width
                self.nextButtonWidthConstraint.animator().constant += self.nextButtonSizeIncrease
                self.mainTitleLabel.animator().alphaValue = 0.0
                self.showScreenCheckbox.animator().alphaValue = 1.0
            }, completionHandler: {
                self.nextButton.title = "Open Instrument Data"
                self.isAnimatingCarousel = false
                self.mainTitleLabel.hidden = true
                self.importUserEducationView.animate()
            })
        default:
            openFileAndDismiss(sender)
        }
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        
        if isAnimatingCarousel {
            return
        }
        
        switch (currentIndex) {
        case 1:
            backButton.enabled = false
            isAnimatingCarousel = true
            NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
                context.duration = 0.5
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.carouselPositionConstraint.animator().constant += self.view.frame.width
                }, completionHandler: {
                    self.isAnimatingCarousel = false
                    self.exportUserEducationView.animate()
            })
        case 2:
            self.nextButton.title = "Next"
            isAnimatingCarousel = true
            mainTitleLabel.hidden = false
            assignUserEducationView.plotView.connectionViews.forEach({ $0.sizeToAnimate() })
            NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
                context.duration = 0.5
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.carouselPositionConstraint.animator().constant += self.view.frame.width
                self.nextButtonWidthConstraint.animator().constant -= self.nextButtonSizeIncrease
                self.mainTitleLabel.animator().alphaValue = 1.0
                self.showScreenCheckbox.animator().alphaValue = 0.0
                }, completionHandler: {
                    self.isAnimatingCarousel = false
                    self.showScreenCheckbox.hidden = true
                    self.assignUserEducationView.animate()
            })
        default:
            backButton.enabled = false
        }
    }
    
    func openFileAndDismiss(sender: AnyObject) {
        self.view.window?.close()
        NSDocumentController.sharedDocumentController().openDocument(sender)
    }
    
}
