//
//  HistoryViewController.swift
//  Scorer
//
//  Created by Johnson Zhou on 18/09/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa


enum SortType {
    case alpha
    case revAlpha
    case noSort
}



protocol GameViewDelegate {
    var games: [GameEntity]! { get set }
}

protocol AddGameDelegate {
    func reloadGameData() -> ()
}

protocol SortDelegate {
    var byName: String? { get set }
    var sortType: SortType? { get set }
}



class PastGames {}  // Past Game Row Stub

class HistoryViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, GameViewDelegate, NSTableViewDelegate, NSTableViewDataSource, AddGameDelegate, SortDelegate {
    
    var byName: String? { didSet { filter() }}
    var sortType: SortType? { didSet { sort() }}
    
    func reloadGameData() {
        games.removeAll()
        fetchData()
        filter()
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)
    }
    
    func sort() {
        usedGames.sort { (game1, game2) -> Bool in
            return game1.team1Name! < game2.team2Name!
        }
    }
    
    func filter() {
        
        if let name = byName, name != "None"  {
            usedGames = games.filter() { return  ($0.team1Name == name) || ($0.team2Name == name) }
        } else {
            usedGames = games
        }
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)
    }

    var games: [GameEntity]! = [GameEntity]()
    var usedGames = [GameEntity]()
    var currentIndex: Int?
    var currentGame: GameEntity?

    var context: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var firstTeamName: NSTextField!
    @IBOutlet weak var secondTeamName: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
       
        
        // UI
        box.cornerRadius = 0
        gameView.isHidden = true
        
        // Core Data
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        context = appDelegate.persistentContainer.viewContext
        
        //initData()

        fetchData()
        filter()
        
        outlineView.dataSource = self
        outlineView.delegate = self

        gameView.setUp()
        
        outlineView.expandItem(nil, expandChildren: true)
        //outlineView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
        tableView.dataSource = self
        tableView.delegate = self

//      tableView.reloadData()
        
        
        deletebtn.isEnabled = false
        
        
    }
    
    @IBAction func deleteCurrentGame(_ sender: NSButton) {
        context.delete(currentGame!)
        try? context.save()
        games.remove(at: currentIndex!)
        filter()
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)
    }
    
    func setupTable() {
        tableView.tableColumns[1].headerCell.title = currentGame?.team1Name ?? ""
        tableView.tableColumns[2].headerCell.title = currentGame?.team2Name ?? ""
        
        
        self.tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print("data cell setup")
        for (index, column) in tableView.tableColumns.enumerated() {
            if column == tableColumn {
                switch index {
                case 0:  let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "num"), owner: nil) as? NSTableCellView
                cell?.textField?.stringValue = "\(row + 1)"
                return cell
                case 1: let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "num"), owner: nil) as? NSTableCellView
                if let string = currentGame?.team1![row] {
                    cell?.textField?.stringValue = String(string)
                } else {
                    cell?.textField?.stringValue = ""
                }
                return cell
                case 2: let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "num"), owner: nil) as? NSTableCellView
                if let string = currentGame?.team2![row] {
                    cell?.textField?.stringValue = String(string)
                } else {
                    cell?.textField?.stringValue = ""
                }
                return cell
                default: return nil
                }
            }
        }
        return nil
    }
    
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        tableView.reloadData()
        save()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        games.removeAll()
        fetchData()
        tableView.reloadData()
    }
    
    fileprivate func save() {
        do {
            try context.save()
        } catch (let error) {
            print("Error message " + error.localizedDescription)
        }
    }
    
    fileprivate func initData() {
        deleteAll()
        
        
        games.removeAll()
        games = [
            Game.createGame(team1Score: 25, team2Score: 17, team1Name: "YK Pao", team2Name: "KCIS", gameType: .Volleyball, scores1: [12, 13, 14, 15], scores2: [2, 3, 4, 5]),
            Game.createGame(team1Score: 10, team2Score: 0, team1Name: "SHIS", team2Name: "YK Pao", gameType: .Swimming, scores1: [12, 13, 14, 15], scores2: [2, 3, 4, 5]),
            Game.createGame(team1Score: 10, team2Score: 0, team1Name: "SHIS", team2Name: "YK Jr", gameType: .Swimming, scores1: [12, 13, 14, 15], scores2: [2, 3, 4, 5])
        ]
        filter()
        outlineView.reloadData()
    }
    
    fileprivate func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GameEntity")
        request.returnsObjectsAsFaults = false
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try? context.execute(deleteRequest)
    }
    
    // All GameEntity managed objects fetched and appended into [Game]
    fileprivate func fetchData() {
        games.removeAll()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GameEntity")
        request.returnsObjectsAsFaults = false
        
        
        if games == nil {
            games = [GameEntity]()
        }
        do {
            let result = try context.fetch(request)
            for game in result as! [GameEntity] {
                
                guard let t1s = game.value(forKey: "team1Score") as? Int32,
                    let t2s = game.value(forKey: "team2Score") as? Int32,
                    let t1n = game.value(forKey: "team1Name") as? String,
                    let t2n = game.value(forKey: "team2Name") as? String,
                    let gt = game.value(forKey: "gameType") as? Int32,
                    let scores1 = game.value(forKey: "team1") as? [Int],
                    let scores2 = game.value(forKey: "team2") as? [Int]
                else {
                    print("Unwrap failed")
                    return
                }
                games.append(game)
                print(t1n)
            }
        } catch {
            print("An error occurred")
        }
    }
    
    @IBOutlet weak var deletebtn: NSButton!
    @IBAction func deleteGame(_ sender: NSButton) {
        if let game = currentGame {
            context.delete(game)
            try? context.save()
            games.remove(at: currentIndex!)
            filter()
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
            currentGame = nil
        }
    }
    // OutlineView datasource
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        switch item {
        case _ as Game:
            return 0
        case _ as PastGames:
            print("count \(usedGames.count)")
            return usedGames.count
        default:
            return 1
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        switch item {
        case _ as Game:
            return self
        case _ as PastGames:
            return usedGames[index]
        default:
            return PastGames()
        }
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case _ as Game:
            return false
        case _ as PastGames:
            return true
        default:
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        if (item as? Game) == nil {
            return true
        } else {
            return false
        }
    }
    
    // OutlineView delegate
    /*
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let cell = schoolRowView()
        guard let game = item as? Game else {
            fatalError("Unable to read core data memory")
        }
        switch GameType(rawValue: game.game.gameType)! {
        case .Basketball:
            cell.logo = NSImageView(image: NSImage(named: NSImage.Name(rawValue: "bball"))!)
            cell.tf?.placeholderString = "Basketball"
        case .Volleyball:
            cell.logo = NSImageView(image: NSImage(named: NSImage.Name(rawValue: "swimming"))!)
        case .Swimming:
            cell.logo = NSImageView(image: NSImage(named: NSImage.Name(rawValue: "volleyball"))!)
        }
        return cell
    } */
    
    // NSOutlineViewDelegate
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let game = item as? GameEntity {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as! NSTableCellView
            view.textField!.stringValue = game.team1Name! + " vs " + game.team2Name!

            switch GameType(rawValue: game.gameType)! {
            case .Basketball:
                view.imageView!.image = NSImage(named: NSImage.Name(rawValue: "bball"))!
            case .Volleyball:
                view.imageView!.image = NSImage(named: NSImage.Name(rawValue: "swimming"))!
            case .Swimming:
                view.imageView!.image = NSImage(named: NSImage.Name(rawValue: "volleyball"))!
            }
            
            return view
            
        } else {
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as! NSTableCellView
            
            view.textField!.stringValue = "PAST GAMES"
            
            return view
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {

        let outlineView = notification.object as! NSOutlineView
        let selectedIndex = outlineView.selectedRow
        
        gameView.isHidden = false
        
        if selectedIndex > 0 {
            currentGame = usedGames[selectedIndex-1]
            currentIndex = selectedIndex - 1
            setupTable()
            if selectedIndex > 0 {
                firstTeamName.stringValue = currentGame?.team1Name ?? ""
                secondTeamName.stringValue = currentGame?.team2Name ?? ""
            }
            deletebtn.isEnabled = true
        } else {
            currentGame = nil
            currentIndex = nil
            deletebtn.isEnabled = false
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier!.rawValue {
        case "Add":
            if let vc = segue.destinationController as? AddViewController {
                vc.delegate = self
            }
        case "Sort":
            if let vc = segue.destinationController as? SortViewController {
                vc.delegate = self
                vc.selectedSort = sortType
                vc.byName = byName
            }
        default:
            return
        }
    }
    
    /*
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let gameView = GameView()
        guard let game = item as? Game else {
            fatalError("Unable to read core data memory")
        }
        gameView.game = game
        gameView.delegate = self
        
        return gameView
    }
  */
}


