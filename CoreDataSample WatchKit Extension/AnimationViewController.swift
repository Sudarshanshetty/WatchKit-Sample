//
//  AnimationViewController.swift
//  CoreDataSample
//
//  Created by sudarshan  shetty on 4/8/15.
//  Copyright (c) 2015 Sudarshan Shetty. All rights reserved.
//

import WatchKit
import Foundation

class AnimationViewController: WKInterfaceController
{
    
    @IBOutlet weak var theimage: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        theimage.setImageNamed("image")
        
        // Use this for Default Settings
        //minionsFunImage.startAnimating()
        
        theimage.startAnimatingWithImagesInRange(
            NSRange(location: 1, length: 132),
            duration: 5,
            repeatCount: 1)
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}