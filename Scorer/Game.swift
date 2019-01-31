//
//  Game.swift
//  Scorer
//
//  Created by Johnson Zhou on 29/04/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Foundation
import Cocoa


class Game {
    // Core Data
    
    static func deleteGame(name: String) {
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GameEntity")
        request.predicate = NSPredicate(format: "name == %@", name)
        request.returnsObjectsAsFaults = false
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try? context.execute(deleteRequest)
    }
    
    
    static func createGame(team1Score: Int, team2Score: Int, team1Name: String, team2Name: String, gameType: GameType, scores1: [Int], scores2: [Int]) -> GameEntity {
        
        // Create a new Game
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let game = GameEntity(context: context)
        game.team1Score = Int32(team1Score)
        game.team2Score = Int32(team2Score)
        game.team1Name = team1Name
        game.team2Name = team2Name
        game.gameType = gameType.rawValue
        
        game.team1 = scores1
        game.team2 = scores2
        
        game.addToSchool(School.lookUp(schoolname: team1Name) ?? School.createNew(name: team1Name))
        game.addToSchool(School.lookUp(schoolname: team2Name) ?? School.createNew(name: team2Name))
        try? context.save()
        
        return game
    }

}

class School: SchoolEntity {
    
    static func deleteAllSchools() {
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SchoolEntity")
        request.returnsObjectsAsFaults = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try? context.execute(deleteRequest)
    }
    
    static func createNew(name: String) -> SchoolEntity {
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let school = SchoolEntity(context: context)
        school.name = name
        try? context.save()
        
        return school
    }
    
   
    static func lookUp(schoolname: String) -> SchoolEntity? {
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SchoolEntity")
        request.predicate = NSPredicate(format: "name == %@", schoolname)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            guard let schools = result as? [SchoolEntity] else {
                return nil
            }
            if let school = schools.first {
                print("School with name \(school.value(forKey: "name")!) added.")
                return school
            } else {
                return nil
            }
        } catch {
            print("error: \(error)")
        }
        
        return nil
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        // if let school = lookUp(schoolname: entity.attributesByName.)
    }
}
class Basketball: Game {

}

class Swimming {

}
