//
//  AppDelegate.swift
//  EventfulMac
//
//  Created by Jacob Cho on 2015-02-04.
//  Copyright (c) 2015 Jacob. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var viewController : ViewController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        viewController = ViewController(nibName: "ViewController", bundle: nil)
        
        window.contentView.addSubview(viewController.view)
        viewController.view.frame = (window.contentView as! NSView).bounds
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

