//
//  PlayerEntity+CoreDataClass.swift
//  SquadShuffler
//
//  Created by Anthony Khera on 9/5/24.
//
//

import Foundation
import CoreData

@objc(PlayerEntity)
public class PlayerEntity: NSManagedObject {
    
    var status: PlayerStatus {
        get { return PlayerStatus(rawValue: statusRawValue ?? PlayerStatus.none.rawValue) ?? .none }
        set { self.statusRawValue = newValue.rawValue }
    }
    
    var previousStatus: PlayerStatus {
        get { return PlayerStatus(rawValue: previousStatusRaw ?? PlayerStatus.none.rawValue) ?? .none }
        set { self.previousStatusRaw = newValue.rawValue }
    }
    
    //      Reset player
    func resetPlayer(isSelected: Bool = false) {
        self.previousStatus = .none
        self.status = .none
        self.streak = 0
        self.previousStreak = 0
        self.isSelected = isSelected
        
        objectWillChange.send()
    }
    

    
    // Update the date when a player is added as a participant
    func updateDateLastUsed() {
        dateLastUsed = Date()
    }
    
}

enum PlayerStatus: String {
    case none = "none"
    case manualIn = "manualIn"
    case manualOut = "manualOut"
    case autoIn = "autoIn"
    case autoOut = "autoOut"
}
