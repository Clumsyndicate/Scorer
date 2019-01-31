//
//  DataStruct.swift
//  Scorer
//
//  Created by Johnson Zhou on 21/09/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Foundation

class DataStruct {
    
    // Storage
    
    var games: [GameEntity]
    
    // Calculated Properties
    
    var gameNum: Int {
        return games.count
    }
    
    func filter(function: (GameEntity) -> Bool) -> [GameEntity] {
        var result = [GameEntity]()
        for game in games {
            if function(game) {
                result.append(game)
            }
        }
        return result
    }
    
    func sort() {
        games.sorted(by: { return $0.team1Name! < $1.team2Name! })
    }
    /*
    func alpha(g1: Game, g2: Game) -> Bool {
        if g1.team1Name > g2.team1Name {
            
        }
        return true
    }
    */
    init(games: [GameEntity]) {
        self.games = games
    }
    
}
