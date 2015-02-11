//
//  Event.swift
//  EventfulMac
//
//  Created by Jacob Cho on 2015-02-04.
//  Copyright (c) 2015 Jacob. All rights reserved.
//

import Cocoa

enum Category {
    case Music
    case Sports
    case PerformingArts
}

class Event: NSObject {
    
    var title : NSString
    var venue : NSString
    var date : NSString
    var performers : [String]?
    var imageURL : NSString?
    var image : NSImage?
    var type : Category?
    var latitude : NSString?
    var longitude : NSString?
    
    init(title : NSString, venue : NSString, date: NSString) {
        self.title = title
        self.venue = venue
        self.date = date
    }

}
