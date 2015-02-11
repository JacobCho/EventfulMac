//
//  EventTableCellView.swift
//  EventfulMac
//
//  Created by Jacob Cho on 2015-02-04.
//  Copyright (c) 2015 Jacob. All rights reserved.
//

import Cocoa

class EventTableCellView: NSTableCellView {
    
    @IBOutlet weak var titleLabel : NSTextField!
    @IBOutlet weak var venueLabel : NSTextField!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
