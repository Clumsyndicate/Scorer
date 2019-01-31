//
//  ViewController.swift
//  Scorer
//
//  Created by Johnson Zhou on 06/02/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa
import CoreData

protocol SettingsViewControllerDelegate {
    var team1ScoreInt: Int { get set }
    var team2ScoreInt: Int { get set }
    var team1Name: NSTextField! { get set }
    var team2Name: NSTextField! { get set }
    var gameType: GameType { get set }
    var gameNum: Int { get set }
    var fontType: FontType { get set }
    var length: Double { get set }
}

struct Constants {
    static let startTime = 10.0   // In minutes
}



class ScoreViewController: NSViewController, SettingsViewControllerDelegate {

    @IBOutlet weak var team1Name: NSTextField!
    @IBOutlet weak var team2Name: NSTextField!
    @IBOutlet weak var team1Score: NSTextField!
    @IBOutlet weak var team2Score: NSTextField!
    
    var games = [Game]()
    
    // Online Sync
    
    var syncTimer: Timer!
    var socket: SIO!
    
    @IBAction func goLive(_ sender: NSButton) {
        if syncTimer == nil {
            syncTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sync), userInfo: nil, repeats: true)
        }
        socket = SIO()
        socket.connect(address: "http://127.0.0.1:5000/")
    }
    
    func startSync() {
        print("Sync started")
        syncTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sync), userInfo: nil, repeats: true)
        socket = SIO()
        socket.connect(address: "http://127.0.0.1:5000/")

    }
    
    @objc func sync() {
        
        socket.update(t1N: self.team1Name.stringValue,
                      t2N: self.team2Name.stringValue,
                      t1S: Int(self.team1Score.stringValue) ?? 0,
                      t2S: Int(self.team2Score.stringValue) ?? 0,
                      gt: self.gameType,
                      time: Double(self.time) / 100 ,
                      gNum: gameNum,
                      timerState: timerIsRunning)
        print("Synchronized, time: \(self.time)")
    }

    // Mark: Time Management
    
    var timerIsRunning = false
    var startTime: Double = 0

    
    var length: Double = Constants.startTime * 60.0 {
        didSet {
            ti = length * 100
        }
    }
    
    var timer = Timer()
    
    var ti: Double = Constants.startTime * 60 * 100
    var time: Int {
        return Int(ti - D_time * 100)
    }
    
    var D_time: Double = 0.0
    var resetCheck: Bool = true
    var afterpause: Bool = false
    
    @IBOutlet weak var timeLabel: NSTextField!
    
    func initialize() {
        if resetCheck {
            
            startTime = Date().timeIntervalSinceReferenceDate
            resetCheck = false
        }
        timer = Timer.scheduledTimer(timeInterval: 0.01,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func retire() {
        timer.invalidate()
    }
    
    @objc func advanceTimer(timer: Timer) {
        
        //Total time since timer started, in seconds
        let timeElapsed = Date().timeIntervalSinceReferenceDate - startTime
        if time >= 0 {
            D_time = timeElapsed
        } else {
            timer.invalidate()
        }
        //The rest of your code goes here
        
        //Convert the time to a string with 2 decimal places
        
        //Display the time string to a label in our view controller
        timeLabel.stringValue = makeTimeString()
    }
    
    func runTimer() {
        if !timerIsRunning {
            initialize()
            
            timerIsRunning = true
        }
    }
    
    
    func makeTimeString() -> String {
        
        return "\(time / 6000):\((time % 6000) / 100 < 10 ? "0" + String((time % 6000) / 100) : String((time % 6000) / 100)):\(time % 100 < 10 ? "0"+String(time % 100) : String(time % 100))"
    }
    
    @IBAction func pauseTimer(sender: Any) {
        if timerIsRunning {
            retire()
            ti -= D_time * 100
            timerIsRunning = false
        } else {
            startTime = Date().timeIntervalSinceReferenceDate
            initialize()
            timerIsRunning = true
        }
        // timeLabel.stringValue = makeTimeString()
        sync()
    }
    
    @IBAction func resetTImer(_ sender: NSButton) {
        timerIsRunning = false
        retire()
        resetCheck = true
        length = Constants.startTime * 60.0
        D_time = 0.0
        timeLabel.stringValue = makeTimeString()
    }
    
    // Mark: Game Number
    
    @IBOutlet weak var gameNumTextField: NSTextField!
    @IBAction func gameNumClicked(_ sender: NSClickGestureRecognizer) {
        gameNumTextField.stringValue = String(Int(gameNumTextField.stringValue)! + 1)
    }
    
    var fontType: FontType = .Medium {
        didSet {
             setFont(fontType: fontType)
        }
    }
    
    var gameNum: Int {
        get {
            return Int(gameNumTextField.stringValue)!
        }
        set {
            gameNumTextField.stringValue = "\(newValue)"
        }
    }
    
    // Mark: Font Control Setup
    
    private func namefont(of size: Int) -> NSFont? {
        return NSFont(descriptor: team1Name.font!.fontDescriptor, size: CGFloat(size))
    }
    private func scorefont(of size: Int) -> NSFont? {
        return NSFont(descriptor: team1Score.font!.fontDescriptor, size: CGFloat(size))
    }
    private func setFont(fontType: FontType) {
        switch fontType {
        case .Large:
            team1Name.font = namefont(of: 100)
            team2Name.font = namefont(of: 100)
            team1Score.font = scorefont(of: 200)
            team2Score.font = scorefont(of: 200)
            
        case .Medium:
            team1Name.font = namefont(of: 70)
            team2Name.font = namefont(of: 70)
            team1Score.font = scorefont(of: 150)
            team2Score.font = scorefont(of: 150)
        case .Small:
            team1Name.font = namefont(of: 50)
            team2Name.font = namefont(of: 50)
            team1Score.font = scorefont(of: 120)
            team2Score.font = scorefont(of: 120)
        }
    }
    
    // Mark: game Icon
    
    var gameIconNames: [GameType: String] = [
        .Basketball: "bball",
        .Volleyball: "volleyball",
        .Swimming: "swimming"
    ]
    
    var gameType: GameType = .Basketball {
        didSet {
            gameIcon.image = NSImage(named: NSImage.Name(rawValue: gameIconNames[gameType]!))
        }
    }
    
    @IBOutlet weak var gameIcon: NSImageView!
    
    // Mark: Score keeping
    
    var team1ScoreInt: Int = 0 {
        didSet {
            team1Score.stringValue = String(team1ScoreInt)
        }
    }
    var team2ScoreInt: Int = 0 {
        didSet {
            team2Score.stringValue = String(team2ScoreInt)
        }
    }
    
    // Mark: Keyboard control
    
    
    
    @IBAction func addTeam1(sender: Any) {
        team1ScoreInt += 1
        sync()
    }
    
    @IBAction func addTeam2(sender: Any) {
        team2ScoreInt += 1
        sync()
    }
    
    @IBAction func subtractTeam1(sender: Any) {
        if team1ScoreInt > 0 {
            team1ScoreInt -= 1
            sync()
        }
    }
    
    @IBAction func subtractTeam2(sender: Any) {
        if team2ScoreInt > 0 {
            team2ScoreInt -= 1
            sync()
        }
    }
    
    // Mark: Seguing
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        print("prepare")
        if segue.identifier!.rawValue == "settingsSegue" {
            print("first if passeed")
            if let vc1 = segue.destinationController as? NSWindowController {
                if let vc = vc1.contentViewController as? SettingsViewController {
                    vc.team1ScoreInt = team1ScoreInt
                    vc.team2ScoreInt = team2ScoreInt
                    vc.team1NameString = team1Name.stringValue
                    vc.team2NameString = team2Name.stringValue
                    vc.settingsDelegate = self
                    vc.gameType = gameType
                    vc.gameNum = gameNum
                    vc.fontType = fontType
                    
                    vc.initializeProperties()
                    print("yeah!")

                }
            }
        } else if segue.identifier!.rawValue == "History" {
            if let vc = segue.destinationController as? HistoryViewController {
                
            }
        }
    }

    @IBOutlet weak var progressbtn: NSButton!
    @IBAction func progress(_ sender: NSButton) {
        gameNum += 1
        if gameNum == 4 {
            progressbtn.stringValue = "Finish"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        team1ScoreInt = 0
        team2ScoreInt = 0
                
        view.wantsLayer = true
        // view.layer?.backgroundColor = NSColor.white.cgColor
        
        // runTimer()
        timeLabel.stringValue = makeTimeString()
        // startSync()
    }

    
    
    


}

