//
//  Timer.swift
//  Scorer
//
//  Created by Johnson Zhou on 13/09/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Foundation

class Custom_Timer {
    var startTime: Double = 0
    var time: Double = 0
    var timer: Timer?
    
    var t: Double
    
    /*
     When the view controller first appears, record the time and start a timer
     */
    init(t: Double) {
        self.t = t
    }
    
    func initialize() {
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    //When the view controller is about to disappear, invalidate the timer
    
    func retire() {
        timer?.invalidate()
    }
    
    
    @objc func advanceTimer(timer: Timer) {
        
        //Total time since timer started, in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
        
        //The rest of your code goes here
        
        //Convert the time to a string with 2 decimal places
        let timeString = String(format: "%.2f", time)
        
        //Display the time string to a label in our view controller
    }
}

