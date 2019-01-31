//
//  AddViewController.swift
//  Scorer
//
//  Created by Johnson Zhou on 15/01/2019.
//  Copyright © 2019 Johnson Zhou. All rights reserved.
//

import Cocoa

class AddViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
    @IBOutlet weak var team1PopUpButton: NSPopUpButton!
    @IBOutlet weak var team2PopUpButton: NSPopUpButton!
    
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
    
    var school1: SchoolEntity {
        return schools.filter { return  $0.name == team1PopUpButton.selectedItem?.title }.first!
    }
    
    var school2: SchoolEntity {
        return schools.filter { return  $0.name == team2PopUpButton.selectedItem?.title }.first!
    }
    @IBOutlet weak var s11: NSTextField!
    @IBOutlet weak var s12: NSTextField!
    @IBOutlet weak var s13: NSTextField!
    @IBOutlet weak var s14: NSTextField!
    @IBOutlet weak var s21: NSTextField!
    @IBOutlet weak var s23: NSTextField!
    @IBOutlet weak var s24: NSTextField!
    @IBOutlet weak var s22: NSTextField!

    @IBAction func save(_ sender: NSButton) {
        _ = Game.createGame(team1Score: 0, team2Score: 0, team1Name: school1.name!, team2Name: school2.name!, gameType: .Basketball, scores1: [Int(s11.stringValue)!, Int(s12.stringValue)!, Int(s13.stringValue)!, Int(s14.stringValue)!], scores2: [Int(s21.stringValue)!, Int(s22.stringValue)!, Int(s23.stringValue)!, Int(s24.stringValue)!])
        
        delegate.reloadGameData()
        dismissViewController(self)
    }
    
    @IBAction func cancel(_ sender: NSButton) {
        dismissViewController(self)
    }
    
    var delegate: AddGameDelegate!
    
}


class SortViewController: NSViewController {
    
    
    var delegate: SortDelegate!
    
    var schools: [SchoolEntity]!
    var context: NSManagedObjectContext!
    
    var selectedSort: SortType?
    var byName: String?
    
    @IBOutlet weak var sortbtn: NSPopUpButton!
    @IBOutlet weak var filterbtn: NSPopUpButton!
    
    @IBAction func sort(_ sender: NSPopUpButton) {
        if let selected = sender.selectedItem?.title {
            switch selected{
            case "Alpha":
                delegate.sortType = .alpha
            case "R-Alpha":
                delegate.sortType = .revAlpha
            case "Normal":
                delegate.sortType = .noSort
            default:
                return
            }
        }
    }
    
    @IBAction func filter(_ sender: NSPopUpButton) {
        delegate.byName = filterbtn.selectedItem?.title
    }
    
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
        filterbtn.removeAllItems()
        for school in schools {
            if let name = school.name {
                filterbtn.addItem(withTitle: name)
            } else {
                fatalError("School without a name")
            }
        }
        filterbtn.addItem(withTitle: "None")
    }
    
    override func viewDidLoad() {
        filterbtn.selectItem(withTitle: "None")
        fetchTeamData()
        loadSchoolEntities()
        
        if let selectedSort = selectedSort {
            switch selectedSort {
            case .alpha: sortbtn.selectItem(withTitle: "Alpha")
            case .noSort: sortbtn.selectItem(withTitle: "R-Alpha")
            case .revAlpha: sortbtn.selectItem(withTitle: "Normal")
            }
        }
        
        if let name = byName {
            sortbtn.selectItem(withTitle: name)
        }
    }
}
