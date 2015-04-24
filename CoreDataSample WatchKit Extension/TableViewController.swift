//
//  TableViewController.swift
//  CoreDataSample
//
//  Created by sudarshan  shetty on 4/8/15.
//  Copyright (c) 2015 Sudarshan Shetty. All rights reserved.

import WatchKit
import Foundation

class TableViewController: WKInterfaceController
{
    
    @IBOutlet weak var thetable: WKInterfaceTable!
    
     var thecontroller = ["Barca1" ,"Barca2" ,"Barca3" ,"Barca4" ,"Barca5"]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.loadthetableview();
    }
    
    
    func loadthetableview()
    {
        thetable.setNumberOfRows(thecontroller.count, withRowType: "therows")
        for (index, value) in enumerate(thecontroller) {
            if let row = thetable.rowControllerAtIndex(index) as? rowcontroller {
                row.thelabel.setText(value)
                row.theImage.setImageNamed("fb")
            }
        }
        
    }
    
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        
    }
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        return thecontroller[rowIndex];
    }

    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
