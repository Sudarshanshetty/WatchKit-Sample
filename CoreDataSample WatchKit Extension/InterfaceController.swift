//
//  InterfaceController.swift
//  CoreDataSample WatchKit Extension
//
//  Created by sudarshan  shetty on 4/7/15.
//  Copyright (c) 2015 Sudarshan Shetty. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var openApp: WKInterfaceButton!

    
    @IBOutlet weak var thetable: WKInterfaceTable!
    
    @IBOutlet weak var thecontrollers: WKInterfaceButton!
  
    @IBOutlet weak var speak: WKInterfaceButton!
    
    
    @IBOutlet weak var record: WKInterfaceButton!
    
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    @IBAction func onSpeak() {
    
       self.presentTextInputControllerWithSuggestions(["sug1","sug2"] ,allowedInputMode: .Plain, completion: { (selectedAnswers) -> Void in
           if ((selectedAnswers != nil) && (selectedAnswers.count>0) )
           {
               if let spokenReply = selectedAnswers[0] as? String {
                   println(spokenReply)
           }
           }
       })
    }
   
    @IBAction func openparent() {
        
        let testDict  = ["request" : "catch"]

        
        WKInterfaceController.openParentApplication(testDict,
            reply: {(reply, error) -> Void in
                self.openApp.setTitle("opened")
            
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
       // self.loadthetableview();
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
