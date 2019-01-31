//
//  SettingsViewController.swift
//  Scorer
//
//  Created by Johnson Zhou on 06/02/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa

enum GameType: Int32 {
    case Basketball = 1
    case Volleyball = 2
    case Swimming = 3
}

enum FontType {
    case Small
    case Medium
    case Large
}

class SettingsViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var team1PopUp: NSPopUpButton!
    @IBOutlet weak var team2PopUp: NSPopUpButton!
    @IBOutlet weak var team1Score: NSTextField!
    @IBOutlet weak var team2Score: NSTextField!
    

    
    // Mark: Timer
    
    
    func timeIntervalToString(ti: TimeInterval) -> String {
      
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.minute, .second, .nanosecond]
        return dcf.string(from: ti)!
    }
    
    var settingsDelegate: SettingsViewControllerDelegate!
    
    var team1ScoreInt: Int! 
    var team2ScoreInt: Int!
    
    var team1NameString: String!
    var team2NameString: String!
    
    var gameType: GameType!
    
    var gameNum: Int!
    
    var fontType: FontType!
    
    @IBOutlet weak var gameTypePopup: NSPopUpButton!
    
    func titleOfSport(type: GameType) -> String {
        switch type {
        case .Basketball:
            return "Basketball"
        case .Volleyball:
            return "Volleyball"
        case .Swimming:
            return "Swimming"
        }
    }
    
    @IBAction func NSPopUpButtonAction(_ sender: NSPopUpButton) {
        
        print(sender.selectedItem!.title)
        switch sender.selectedItem!.title {
        case "Basketball":
            gameType = .Basketball
        case "Volleyball":
            gameType = .Volleyball
        case "Swimming":
            gameType = .Swimming
        default:
            break
        }
    }
    
    
    @IBOutlet weak var fontSizePopUp: NSPopUpButton!
    @IBAction func fontSizePopUpButtonAction(_ sender: NSPopUpButton) {
        switch sender.selectedItem!.title {
        case "Small":
            fontType = FontType.Small
        case "Medium":
            fontType = .Medium
        case "Large":
            fontType = .Large
        default:
            break
        }
    }
    
    @IBOutlet weak var team1PopUpButton: NSPopUpButton!
    @IBAction func team1PopUpButtonAction(_ sender: NSPopUpButton) {
    }
    
    @IBOutlet weak var team2PopUpButton: NSPopUpButton!
    @IBAction func team2PopUpButtonAction(_ sender: NSPopUpButton) {
        
    }
    
    private func save() {
        team1ScoreInt = Int(team1Score.stringValue)!
        team2ScoreInt = Int(team2Score.stringValue)!
        settingsDelegate.team1ScoreInt = team1ScoreInt
        settingsDelegate.team2ScoreInt = team2ScoreInt
        settingsDelegate.team1Name.stringValue = team1PopUpButton.selectedItem!.title
        settingsDelegate.team2Name.stringValue = team2PopUpButton.selectedItem!.title
        
        settingsDelegate.gameType = gameType
        settingsDelegate.gameNum = Int(gameNumTextField.stringValue)!
        settingsDelegate.fontType = fontType
        
    }

    @IBAction func saveSettings(_ sender: NSButton) {
        save()
        
        self.view.window?.close()
    }
    @IBAction func cancelSettings(_ sender: NSButton) {
        // dismissViewController(self)
        self.view.window?.close()
        
    }
    
    
    override func controlTextDidChange(_ obj: Notification) {
        print("text did change")
    }
    
    @IBOutlet weak var gameNumTextField: NSTextField!
    
    
    // var isSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
            //initializeProperties()
        
        indicator.isHidden = true
        
        // Setting up Core Data and loading team history
        
    }
    
    override func viewWillAppear() {
        initializeProperties()
    }
    
    func initializeProperties() {
        team1Score.stringValue = String(team1ScoreInt)
        team2Score.stringValue = String(team2ScoreInt)
 
        
        // team1Name.stringValue = team1NameString
        // team2Name.stringValue = team2NameString
        
        // team1Name.delegate = self
        // team2Name.delegate = self
        team1Score.delegate = self
        team2Score.delegate = self
        //gameNumTextField.stringValue = String(gameNum)
        
        gameNumTextField.stringValue = "\(gameNum!)"
        
        switch fontType! {
        case .Small:
            fontSizePopUp.selectItem(withTitle: "Small")
        case .Medium:
            fontSizePopUp.selectItem(withTitle: "Medium")
        case .Large:
            fontSizePopUp.selectItem(withTitle: "Large")
        }
        
        gameTypePopup.selectItem(withTitle: titleOfSport(type: gameType))
        
        fetchTeamData()
        loadSchoolEntities()
    }
    
    var schools: [SchoolEntity]!
    var context: NSManagedObjectContext!
    
    fileprivate func fetchTeamData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SchoolEntity")
        request.returnsObjectsAsFaults = false
        
        schools = [SchoolEntity]()
        context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
        do {
            let result = try context.fetch(request)
            for school in result as! [SchoolEntity] {
                schools.append(school)
            }
        } catch {
            print("An error occured")
        }
    }
    
    fileprivate func loadSchoolEntities() {
        team1PopUpButton.removeAllItems()
        for school in schools {
            if let name = school.name {
                team1PopUpButton.addItem(withTitle: name)
            } else {
                fatalError("School without a name")
            }
        }
        team2PopUpButton.removeAllItems()
        for school in schools {
            if let name = school.name {
                team2PopUpButton.addItem(withTitle: name)
            } else {
                fatalError("School without a name")
            }
        }
    }
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var addSchoolTB: NSTextField!
    @IBAction func addSchool(_ sender: NSButton) {
        //indicator.isHidden = false
        indicator.startAnimation(self)
        School.createNew(name: addSchoolTB.stringValue)
        indicator.stopAnimation(self)
        //indicator.isHidden = true
        loadSchoolEntities()
    }
    
    
}
