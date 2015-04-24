//
//  RecorderController.swift
//  CoreDataSample
//
//  Created by sudarshan  shetty on 4/7/15.
//  Copyright (c) 2015 Sudarshan Shetty. All rights reserved.
//

import Foundation
import AVFoundation
import WatchKit

class RecorderViewController: WKInterfaceController {
    
    var recorder: AVAudioRecorder!
    
    var player:AVAudioPlayer!
    
    @IBOutlet weak var recordButton: WKInterfaceButton!
    
    @IBOutlet weak var stopButton: WKInterfaceButton!

    
    @IBOutlet weak var playButton: WKInterfaceButton!
    
    
    @IBOutlet weak var statusLabel: WKInterfaceButton!
    
    var meterTimer:NSTimer!
    
    var soundFileURL:NSURL?
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        

        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        stopButton.setEnabled(false)
        playButton.setEnabled(false)
        setSessionPlayback()
        askForNotifications()

        
        }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
func updateAudioMeter(timer:NSTimer) {
        
        if recorder.recording {
            let dFormat = "%02d"
            let min:Int = Int(recorder.currentTime / 60)
            let sec:Int = Int(recorder.currentTime % 60)
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
           // statusLabel.setText = s
            recorder.updateMeters()
            var apc0 = recorder.averagePowerForChannel(0)
            var peak0 = recorder.peakPowerForChannel(0)
        }
    }
    

    
    @IBAction func removeAll(sender: AnyObject) {
        deleteAllRecordings()
    }
    
  

    @IBAction func record() {
        
        if player != nil && player.playing {
            player.stop()
        }
        
        if recorder == nil {
            println("recording. recorder nil")
           
           playButton.setEnabled(false)
           stopButton.setEnabled(true)
            
            
            //            recordButton.setTitle("Pause", forState:.Normal)
           
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.recording {
            println("pausing")
            recorder.pause()
            //     recordButton.setTitle("Continue", forState:.Normal)
            
        } else {
            println("recording")
            //            recordButton.setTitle("Pause", forState:.Normal)
            
            playButton.setEnabled(false)
            stopButton.setEnabled(true)
            recorder.record()
            recordWithPermission(false)
        }

        
    }
 
    
    @IBAction func stop() {
        
        println("stop")
        recorder.stop()
        meterTimer.invalidate()
        
        //   recordButton.setTitle("Record", forState:.Normal)
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setActive(false, error: &error) {
            println("could not make session inactive")
            if let e = error {
                println(e.localizedDescription)
                return
            }
        }
        
        
        playButton.setEnabled(true)
        stopButton.setEnabled(false)
        recordButton.setEnabled(true)
        recorder = nil
    }
    
    
    @IBAction func plays() {
        play()
    }
    @IBAction func play(sender: UIButton) {
        
    }
    
    func play() {
        
        println("playing")
        var error: NSError?
        // recorder might be nil
        // self.player = AVAudioPlayer(contentsOfURL: recorder.url, error: &error)
        self.player = AVAudioPlayer(contentsOfURL: soundFileURL!, error: &error)
        if player == nil {
            if let e = error {
                println(e.localizedDescription)
            }
        }
       // player.delegate = self
        player.prepareToPlay()
        player.volume = 1.0
        player.play()
    }
    
    
    
    func setupRecorder() {
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording.m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            println("sound exists")
        }
        
        var recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        var error: NSError?
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                        target:self,
                        selector:"updateAudioMeter:",
                        userInfo:nil,
                        repeats:true)
                } else {
                    println("Permission to record not granted")
                }
            })
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func deleteAllRecordings() {
        var docsDir =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var fileManager = NSFileManager.defaultManager()
        var error: NSError?
        var files = fileManager.contentsOfDirectoryAtPath(docsDir, error: &error) as [String]
        if let e = error {
            println(e.localizedDescription)
        }
        var recordings = files.filter( { (name: String) -> Bool in
            return name.hasSuffix("m4a")
        })
        for var i = 0; i < recordings.count; i++ {
            var path = docsDir + "/" + recordings[i]
            
            println("removing \(path)")
            if !fileManager.removeItemAtPath(path, error: &error) {
                NSLog("could not remove \(path)")
            }
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func askForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"background:",
            name:UIApplicationWillResignActiveNotification,
            object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"foreground:",
            name:UIApplicationWillEnterForegroundNotification,
            object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"routeChange:",
            name:AVAudioSessionRouteChangeNotification,
            object:nil)
    }
    
    func background(notification:NSNotification) {
        println("background")
    }
    
    func foreground(notification:NSNotification) {
        println("foreground")
    }
    
    
    func routeChange(notification:NSNotification) {
        //      let userInfo:Dictionary<String,String!> = notification.userInfo as Dictionary<String,String!>
        //      let userInfo = notification.userInfo as Dictionary<String,[AnyObject]!>
        //  var reason = userInfo[AVAudioSessionRouteChangeReasonKey]
        
        // var userInfo: [NSObject : AnyObject]? { get }
        //let AVAudioSessionRouteChangeReasonKey: NSString!
        
        /*
        if let reason = notification.userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber  {
        }
        
        if let info = notification.userInfo as? Dictionary<String,String> {
        
        
        if let rs = info["AVAudioSessionRouteChangeReasonKey"] {
        var reason =  rs.toInt()!
        
        if rs.integerValue == Int(AVAudioSessionRouteChangeReason.NewDeviceAvailable.toRaw()) {
        }
        
        switch reason  {
        case AVAudioSessionRouteChangeReason
        println("new device")
        }
        
        }
        }
        
        var description = userInfo[AVAudioSessionRouteChangePreviousRouteKey]
        */
        /*
        //        var reason = info.valueForKey(AVAudioSessionRouteChangeReasonKey) as UInt
        //var reason = info.valueForKey(AVAudioSessionRouteChangeReasonKey) as AVAudioSessionRouteChangeReason.Raw
        //var description = info.valueForKey(AVAudioSessionRouteChangePreviousRouteKey) as String
        println(description)
        
        switch reason {
        case AVAudioSessionRouteChangeReason.NewDeviceAvailable.toRaw():
        println("new device")
        case AVAudioSessionRouteChangeReason.OldDeviceUnavailable.toRaw():
        println("old device unavail")
        //case AVAudioSessionRouteChangeReasonCategoryChange
        //case AVAudioSessionRouteChangeReasonOverride
        //case AVAudioSessionRouteChangeReasonWakeFromSleep
        //case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory
        
        default:
        println("something or other")
        }
        */
    }
    
}

// MARK: AVAudioRecorderDelegate
extension RecorderViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
//            println("finished recording \(flag)")
//            stopButton.enabled = false
//            playButton.enabled = true
//            recordButton.setTitle("Record", forState:.Normal)
//            
//            // iOS8 and later
//            var alert = UIAlertController(title: "Recorder",
//                message: "Finished Recording",
//                preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
//                println("keep was tapped")
//            }))
//            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in
//                println("delete was tapped")
//                self.recorder.deleteRecording()
//            }))
//            self.presentViewController(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
}

// MARK: AVAudioPlayerDelegate
extension RecorderViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished playing \(flag)")
        recordButton.setEnabled(true)
        stopButton.setEnabled(false)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
}

