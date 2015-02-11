//
//  NSStringExtension.swift
//  EventfulMac
//
//  Created by Jacob Cho on 2015-02-05.
//  Copyright (c) 2015 Jacob. All rights reserved.
//

import Foundation

extension NSString {
    
    class func prepForJSON(string: NSString) -> String {
        let noCommas = string.stringByReplacingOccurrencesOfString(",", withString: "")
        let noSpaces = noCommas.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        return noSpaces
    }
    
    
    
    
}