//
//  ViewController.swift
//  EventfulMac
//
//  Created by Jacob Cho on 2015-02-04.
//  Copyright (c) 2015 Jacob. All rights reserved.
//

import Cocoa

struct APIStrings {
    
    // Eventful API URL Strings
    static let EFApiRoot = "http://api.eventful.com/json/events/search?"
    static let EFApiKey = "app_key=cSb6h8MsvpCVb3TF"
    static let EFKeywordMethod = "&keywords="
    static let EFLocationMethod = "&location="
    static let EFDateMethod = "&date="
    static let EFWithinMethod = "&within="
    static let EFSortOrderMethod = "&sort_order="
    static let EFPageSizeMethod = "&page_size="
    
    // Google Geocoding API URL Strings
    static let GGApiRoot = "https://maps.googleapis.com/maps/api/geocode/json?"
    static let GGApiKey = "&key=AIzaSyByvqGV_IrWboTFKbFcM6jsGSI6iSSoOnc"
    static let GGAddressMethod = "address="
    
}

class ViewController: NSViewController, NSTextFieldDelegate, NSDatePickerCellDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addressTextField: NSTextField!
    @IBOutlet weak var radiusTextField: NSTextField!
    @IBOutlet weak var startingDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var categoryPopUpButton: NSPopUpButton!
    
    @IBOutlet weak var invalidAddressLabel: NSTextField!
    @IBOutlet weak var invalidRadiusLabel: NSTextField!
    @IBOutlet weak var invalidDateLabel: NSTextField!
    
    var validAddress = false
    var validRadius = false
    var validDates = false
    
    var eventsArray : [Event] = []
    var addressCoordinates : String?
    let categoryPopUpArray = ["Music", "Sports", "Performing Arts"]
    let today = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressTextField.delegate = self
        self.radiusTextField.delegate = self
        self.startingDatePicker.delegate = self
        self.endDatePicker.delegate = self
        self.setupPopupButton()
        
        self.invalidAddressLabel.alphaValue = 0
        self.invalidRadiusLabel.alphaValue = 0
        self.invalidDateLabel.alphaValue = 0
        
        startingDatePicker.dateValue = today
        endDatePicker.dateValue = today.addDays(1)
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        startingDatePicker.formatter = dateFormatter
        endDatePicker.formatter = dateFormatter
        
    }
    
    @IBAction func searchButtonPressed(sender: NSButton) {
        // Clear eventsArray
        self.eventsArray.removeAll(keepCapacity: true)
        self.tableView.reloadData()
        
        var category : String = self.categoryPopUpButton.selectedItem!.title.stringByReplacingOccurrencesOfString(" ", withString: "")

        var urlString = APIStrings.EFApiRoot + APIStrings.EFApiKey +
            APIStrings.EFKeywordMethod + category +
            APIStrings.EFLocationMethod + self.addressCoordinates! +
            APIStrings.EFWithinMethod + self.radiusTextField.stringValue +
            APIStrings.EFDateMethod +
            self.prepDatesForJSON(self.startingDatePicker.stringValue, endDate: self.endDatePicker.stringValue) +
            APIStrings.EFSortOrderMethod + "popularity" + APIStrings.EFPageSizeMethod + "50"

        let url = NSURL(string: urlString)
        
        self.getEventsInBackground(url!)
        
        
    }
    
    // MARK: TableViewDataSource Methods
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.eventsArray.count
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        
        var cellView : NSTableCellView = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as! NSTableCellView
        let event = self.eventsArray[row]
        
        if tableColumn.identifier == "EventColumn" {
            
            cellView.textField?.stringValue = event.title as! String
            
            // If the event has an image, load in background
            if let imageURL = event.imageURL {
                if let image = event.image {
                    cellView.imageView!.image = image
                } else {
                    self.loadImageInBackground(event, cell: cellView)
                }
            }
        }
        
        if tableColumn.identifier == "DateColumn" {
            var eventDate = NSDateFormatter.dateFromEventful(event.date)
            cellView.textField?.stringValue = NSDateFormatter.dateToCell(eventDate) as! String
            
        }
        
        return cellView
    }
    
    // MARK: Networking Methods
    
    func getEventsInBackground(url : NSURL) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url, options: nil, error: nil)
            var jsonError : NSError?
            if let dataDictionary : NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError) as? NSDictionary {
                if let eventsDictionary = dataDictionary["events"] as? NSDictionary {
                    if let eventsList = eventsDictionary["event"] as? NSArray {
                        for event in eventsList {
                            var newEvent = Event(title: event["title"] as! NSString,
                                venue: event["venue_name"] as! NSString,
                                date: event["start_time"] as! NSString)
                            newEvent.latitude = event["latitude"] as? NSString
                            newEvent.longitude = event["longitude"] as? NSString
                            
                            if let images = event["image"] as? NSDictionary {
                                if let medSize = images["medium"] as? NSDictionary {
                                    newEvent.imageURL = medSize["url"] as? NSString
                                }
                            }
                            
                            if let performers = event["performers"] as? NSDictionary {
                                newEvent.performers = []
                                if let performersArray = performers["performer"] as? NSArray {
                                    for performer in performersArray {
                                        newEvent.performers?.append(performer["name"] as! String)
                                    }
                                }
                                if let performer = performers["performer"] as? NSDictionary {
                                    newEvent.performers?.append(performer["name"] as! String)
                                }
                            }
                            
                            self.eventsArray.append(newEvent)
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.eventsArray.sort({ $0.date < $1.date as String})
                    self.tableView.reloadData()
                }
                
                
            } else {
                if let error = jsonError {
                    println(error)
                }
                
            }
        }
        
    }
    
    func loadImageInBackground(event : Event, cell : NSTableCellView) {
        let url = NSURL(string: event.imageURL! as! String)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!, options: nil, error: nil)
            
            dispatch_async(dispatch_get_main_queue()) {
                cell.imageView!.image = NSImage(data: data!)
                event.image = NSImage(data: data!)
            }
        }
        
    }
    
    func getGeocodeInBackground(address : NSString) {
        var lat : Double?
        var lng : Double?
        let urlString = APIStrings.GGApiRoot + APIStrings.GGAddressMethod + NSString.prepForJSON(address)  + APIStrings.GGApiKey
        let url = NSURL(string: urlString)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!, options: nil, error: nil)
            var jsonError : NSError?
            if let dataDictionary : NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError) as? NSDictionary {
                if let locationArray = dataDictionary["results"] as? NSArray {
                    if locationArray.count > 0 {
                        let firstResult : NSDictionary = locationArray[0] as! NSDictionary
                        if let geometry = firstResult["geometry"] as? NSDictionary {
                            if let location = geometry["location"] as? NSDictionary {
                                lat = location["lat"] as? Double
                                lng = location["lng"] as? Double
                                if let latitude = lat, longitude = lng {
                                    self.addressCoordinates = String(stringInterpolationSegment: latitude) + "," + String(stringInterpolationSegment: longitude)
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.validAddress = true
                                        self.checkAllValid()
                                        self.invalidAddressLabel.alphaValue = 0
                                    }
                                }
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            // No location results
                            self.validAddress = false
                            self.checkAllValid()
                            self.invalidAddressLabel.alphaValue = 1

                        }
                    }
                }
                
            }
            else {
                if let error = jsonError {
                    self.validAddress = false
                    self.checkAllValid()
                    println(error)
                }
                
            }
            
        }
        
    }
    
    // MARK: NSTextFieldDelegate Method
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        
        if !self.addressTextField.stringValue.isEmpty {
            self.getGeocodeInBackground(self.addressTextField.stringValue)
        }
        if !self.radiusTextField.stringValue.isEmpty {
            self.checkRadius(self.radiusTextField.stringValue)
        }

    }
    
    // MARK: NSDatePickerDelegate Method
    
    func datePickerCell(aDatePickerCell: NSDatePickerCell, validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate?>, timeInterval proposedTimeInterval: UnsafeMutablePointer<NSTimeInterval>) {
        
        self.checkDates(self.startingDatePicker.dateValue, endDate: self.endDatePicker.dateValue)
        
    }
    
    // MARK: Helper Methods
    func setupPopupButton() {
        categoryPopUpButton.removeAllItems()
        categoryPopUpButton.addItemsWithTitles(categoryPopUpArray)
    }
    
    func checkAllValid() {
        let validSearchArray = [self.validAddress, self.validRadius, self.validDates]
        var allValid = true
        for valid in validSearchArray {
            if valid as Bool == false {
                allValid = false
                self.disableSearchButton()
            }
        }
        if allValid == true {
            self.enableSearchButton()
        }
        
    }
    
    func disableSearchButton() {
        self.searchButton.enabled = false

    }
    
    func enableSearchButton() {
        self.searchButton.enabled = true
    }
    
    func prepDatesForJSON(startDate : String, endDate : String) -> String {
        var start = NSDateFormatter.dateFromDatePicker(startDate)
        var end = NSDateFormatter.dateFromDatePicker(endDate)
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        
        var startString = dateFormatter.stringFromDate(start!)
        var endString = dateFormatter.stringFromDate(end!)
        
        return startString + "00" + "-" + endString + "00"
    }
    
    func checkDates(startDate : NSDate, endDate : NSDate) {
                
                if startDate.compare(endDate) == NSComparisonResult.OrderedDescending // If end date is before start
                    ||
                    startDate.compare(today) == NSComparisonResult.OrderedDescending // If start date is before today
                    ||
                    endDate.compare(today.addDays(28)) == NSComparisonResult.OrderedDescending // If end date is 28 days after today
                    ||
                    endDate.compare(today.addYears(1)) == NSComparisonResult.OrderedDescending // If end date is further than one year away from today
                {
                    self.invalidDateLabel.alphaValue = 1.0
                    self.validDates = false
                    self.checkAllValid()
                }
                    
                else {
                    
                    self.invalidDateLabel.alphaValue = 0.0
                    self.validDates = true
                    self.checkAllValid()
                }
        
    }
    
    func checkRadius(radius : String) {
        
        let numSet = NSCharacterSet.alphanumericCharacterSet()
        let stringSet = NSCharacterSet(charactersInString: radius)
        // Check if string is alphanumeric
        if numSet.isSupersetOfSet(stringSet) {
            
            var radIntValue = radius.toInt()
            
            if radIntValue < 0 || radIntValue > 300 {
                self.validRadius = false
                self.checkAllValid()
                self.invalidRadiusLabel.alphaValue = 1.0
                
            } else {
                if !self.searchButton.enabled {
                    self.invalidRadiusLabel.alphaValue = 0.0
                    self.validRadius = true
                    self.checkAllValid()
                }
                
            }
            
        } else {
            // String is not alphanumeric
            self.validRadius = false
            self.checkAllValid()
        }
        
    }

    
}
