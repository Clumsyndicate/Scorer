//
//  GameView.swift
//  Scorer
//
//  Created by Johnson Zhou on 08/10/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa

class GameView: NSView {
    
    var game: GameEntity?
    var delegate: GameViewDelegate!
    
    @IBOutlet weak var team1: NSTextField!
    @IBOutlet weak var team2: NSTextField!
    
    @IBAction func deleteGame(sender: NSButton) {
        delegate.games = delegate.games.filter { (game) -> Bool in
            if game === self.game! {
                return false
            } else {
                return true
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
    }
    
    
    func setUp() {
        team1.stringValue = game?.team1Name ?? ""
        team2.stringValue = game?.team2Name ?? ""
        
    }
    
}
