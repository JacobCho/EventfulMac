//
//  NSDateExtension.swift
//  EventfulMac
//
//  Created by Jacob Cho on 2015-02-05.
//  Copyright (c) 2015 Jacob. All rights reserved.
//

import Foundation

extension NSDate {
    
    func addDays(x : Int) -> NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: x, toDate: self, options: nil)!
    }
    
    func addYears(x : Int) -> NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitYear, value: x, toDate: self, options: nil)!
    }
}