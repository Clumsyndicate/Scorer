//
//  Socket.swift
//  Scorer
//
//  Created by Johnson Zhou on 22/01/2019.
//  Copyright © 2019 Johnson Zhou. All rights reserved.
//

import Foundation
import SocketIO


struct updateJS: SocketData {
    let t1N, t2N: String
    let t1S, t2S, gNum: Int
    let gameType: GameType
    let time: Double
    let timerState: Bool

    func socketRepresentation() -> SocketData {
        return ["t1N": t1N, "t2N": t2N, "t1S": t1S, "t2S": t2S, "gameType": gameType.rawValue, "time": time, "gNum": gNum, "running": timerState]
    }
}

class SIO {
    
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    func connect(address: String) {

        manager = SocketManager(socketURL: URL(string: address)!, config: [.log(false), .compress])
        socket = manager.defaultSocket
        
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .error) { (data, eck) in
            print(data)
            print("socket error")
        }
        
        socket.on(clientEvent: .disconnect) { (data, eck) in
            print(data)
            print("socket disconnect")
        }
        
        socket.on(clientEvent: SocketClientEvent.reconnect) { (data, eck) in
            print(data)
            print("socket reconnect")
        }
        socket.connect()

        print(socket.debugDescription)
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func update(t1N: String, t2N: String, t1S: Int, t2S: Int,  gt: GameType, time: Double, gNum: Int, timerState: Bool) {
        
        socket.emit("yo", updateJS(t1N: t1N, t2N: t2N, t1S: t1S, t2S: t2S, gNum: gNum, gameType: gt, time: time, timerState: timerState))
    }
}

