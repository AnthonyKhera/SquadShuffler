//
//  GameViewModel.swift
//  SquadShuffler
//
//  Created by Anthony Khera on 9/5/24.
//

import Foundation
import CoreData

class GameViewModel: ObservableObject {
    private let container: NSPersistentContainer
    
    @Published var allPlayers: [PlayerEntity] = []
    @Published var game: GameEntity?
    @Published var showPlayerExistsAlert: Bool = false
    @Published var canReroll: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var showRegAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    var requiredNumPlayers: Int {Int(game!.numGames) * Int(game!.numTeams) * Int(game!.numPlayers)}
    var participants: [PlayerEntity] {allPlayers.filter { $0.isSelected }}
    
    init(container: NSPersistentContainer) {
        self.container = container
        fetchGame()
        fetchAllPlayers()
    }
    
    func fetchAllPlayers() {
        let request: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        do {
            self.allPlayers = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching players: \(error)")
        }
    }
    
    func fetchGame() {
        let request: NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        do {
            if let fetchedGame = try container.viewContext.fetch(request).first {
                self.game = fetchedGame
            } else {
                let newGame = GameEntity(context: container.viewContext)
                newGame.numGames = 1
                newGame.numTeams = 2
                newGame.numPlayers = 1
                newGame.playLimit = 3
                newGame.sitLimit = 2
                newGame.useAutoIn = false
                newGame.useAutoOut = false
                game = newGame
                saveData()
            }
        } catch {
            print("Error fetching game: \(error)")
        }
    }
    
    func addPlayer(playerName: String) {
        if !allPlayers.contains(where: { $0.playerName == playerName }) {
            
            let viewContext = container.viewContext
            let newPlayer = PlayerEntity(context: viewContext)
            
            newPlayer.id = UUID()
            newPlayer.playerName = playerName
            newPlayer.dateLastUsed = Date()
            newPlayer.streak = 0
            newPlayer.previousStreak = 0
            newPlayer.status = .none
            newPlayer.previousStatus = .none
            
            do {
                try viewContext.save()
                fetchAllPlayers()
            } catch let error {
                print("Error saving player: \(error)")
            }
        } else {
            showPlayerExistsAlert = true
        }
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchGame()
            fetchAllPlayers()
        } catch let error {
            print("Error saving data: \(error)")
        }
    }
    
    func deletePlayer(player: PlayerEntity) {
        let viewContext = container.viewContext
        viewContext.delete(player)
        
        do {
            try viewContext.save()
            fetchAllPlayers() // Refresh the list after deleting
        } catch let error {
            print("Error deleting player: \(error)")
        }
    }
    
    func toggleIsSelected(player: PlayerEntity) {
        if player.isSelected {
            player.resetPlayer()
        } else {
            player.isSelected = true
        }
        objectWillChange.send()
        
        self.canReroll = false
        saveData()
    }
    
    func updateParticipants(_ participants: [PlayerEntity]) {
        for player in participants {
            player.updateDateLastUsed()
        }
        
        saveData()
    }
    
    func removeParticipant(indexSet: IndexSet) {
        for index in indexSet {
            participants[index].resetPlayer()
            objectWillChange.send()
        }
        self.canReroll = false
        saveData()
    }
    
    func resetAllParticipants() {
        for player in self.participants {player.resetPlayer(isSelected: true)}
        self.canReroll = false
        saveData()
    }
    
    func removeAllParticipants() {
        for player in self.participants {player.resetPlayer()}
        self.canReroll = false
        saveData()    }
    
    func playPlayer(player: PlayerEntity) {
        let streak = player.streak
        let status = player.status
        
        player.updateDateLastUsed()
        
        player.previousStreak = streak
        player.streak = (streak < 0) ? 1 : streak + 1
        
        player.previousStatus = status
        
        if (status == .autoIn) || (status == .manualIn) {
            player.status = .none
        }
        
        if game!.useAutoOut && (player.streak >= game!.playLimit) {
            player.status = .autoOut
        }
    }
    
    func sitPlayer(player: PlayerEntity) {
        let streak = player.streak
        let status = player.status
        
        player.updateDateLastUsed()
        
        player.previousStreak = streak
        player.streak = (streak > 0) ? -1 : streak - 1
        
        player.previousStatus = player.status
        if (status == .autoOut) || (status == .manualOut) {
            player.status = .none
        }
        
        if game!.useAutoIn && (player.streak <= (game!.sitLimit * (-1))) {
            player.status = .autoIn
        }
    }
    
    func updateGameSettings(numGames: Int32, numTeams: Int32, numPlayers: Int32, useAutoIn: Bool, useAutoOut: Bool, sitLimit: Int32, playLimit: Int32) {
        self.game!.numGames = numGames
        self.game!.numTeams = numTeams
        self.game!.numPlayers = numPlayers
        self.game!.useAutoIn = useAutoIn
        self.game!.useAutoOut = useAutoOut
        self.game!.sitLimit = sitLimit
        self.game!.playLimit = playLimit
        self.canReroll = false
        
        if !useAutoIn {
            for player in self.participants {
                if player.status == .autoIn { player.status = .none}
            }
        } else if !useAutoOut {
            for player in self.participants {
                if player.status == .autoOut { player.status = .none}
            }
        }
        saveData()
    }
    
    func findSittingPlayers(availableParticipants: inout [PlayerEntity], sittingPlayers: inout [PlayerEntity], numSittingPlayers: Int) throws {
        // Sit manualOut players first (they take priority)
        for i in stride(from: availableParticipants.count - 1, through: 0, by: -1) {
            let player = availableParticipants[i]
            if player.status == .manualOut {
                if sittingPlayers.count < numSittingPlayers {
                    sittingPlayers.append(player)
                    availableParticipants.remove(at: i)
                } else {
                    throw AppErrors.tooManySitting
                }
            }
        }
        
        // Sit autoOut players second
        for j in stride(from: availableParticipants.count - 1, through: 0, by: -1) {
            let player = availableParticipants[j]
            
            if player.status == .autoOut {
                if sittingPlayers.count < numSittingPlayers {
                    sittingPlayers.append(player)
                    availableParticipants.remove(at: j)
                } else {
                    alertTitle = "Too Many Play Limits Reached"
                    alertMessage = "Too many players have reached the Play Limit. Some of them will play to fulfill match requirements. Manually designated players will still sit. Consider adjusting your game settings if this issue is recurring."
                    showRegAlert = true
                }
            }
        }
    }
    
    func randomSittingPlayers(availableParticipants: inout [PlayerEntity], sittingPlayers: inout [PlayerEntity], numSittingPlayers: Int) throws {
        var i: Int = availableParticipants.count - 1
        var sitAutoIn: Bool = false
        // [p1, p2, p3, p4]
        while (sittingPlayers.count < numSittingPlayers) && (i >= 0) {
            
            let player = availableParticipants[i]
            
            if player.status == .manualIn { // skip over players that are manually designated to play
                i -= 1
            } else if (player.status != .autoIn) || sitAutoIn { // sit players that have no designation or autoIn (if necessary)
                sittingPlayers.append(player)
                availableParticipants.remove(at: i)
                i -= 1
            } else {
                i -= 1
            }
            
            if i < 0 && (sittingPlayers.count < numSittingPlayers) { // If too many players are designated as in, allow for autoIn players to be sat and start over.
                
                i = availableParticipants.count - 1
                
                if !sitAutoIn {
                    sitAutoIn = true
                } else { // If there are too many players designated as manualIn then don't create the game.
                    throw AppErrors.tooManyPlaying
                }
            }
            
        }
        
        if sitAutoIn {
            alertTitle = "Too Many Sit Limits Reached"
            alertMessage = "Too many players have reached the Sit Limit. Some of them will sit to fulfill match requirements. Manually designated players will still play. Consider adjusting your game settings if this issue is recurring."
            showRegAlert = true
        }
        
    }
    
    func updatePlayers(availableParticipants: inout [PlayerEntity], sittingPlayers: inout [PlayerEntity]) {
        for player in sittingPlayers { sitPlayer(player: player) }
        for player in availableParticipants { playPlayer(player: player)}
    }
    
    func distributePlayers(availableParticipants: inout [PlayerEntity], sittingPlayers: inout [PlayerEntity], numSittingPlayers: Int) -> [String: [String: [[PlayerEntity]]]] {
        var randomizedTeams: [String: [String: [[PlayerEntity]]]] = [:]
        
        for gameIndex in 1...game!.numGames {
            var gameTeams: [[PlayerEntity]] = []
            
            for _ in 1...game!.numTeams {
                var team: [PlayerEntity] = []
                
                for _ in 1...game!.numPlayers {
                    if let player = availableParticipants.popLast() {
                        team.append(player)
                    }
                }
                gameTeams.append(team)
            }
            
            // Store the teams for the current game
            randomizedTeams["Game \(gameIndex)"] = ["Teams": gameTeams]
        }
        
        // Store the list of sitting players
        if numSittingPlayers > 0 { randomizedTeams["Sitting"] = ["Sitting":[sittingPlayers]] }
        return randomizedTeams
    }
    
    func generateRandomTeams() throws -> [String: [String: [[PlayerEntity]]]] {
        var randomizedTeams: [String: [String: [[PlayerEntity]]]] = [:]
        var availableParticipants = participants.shuffled()
        var sittingPlayers: [PlayerEntity] = []
        var numSittingPlayers: Int { allPlayers.filter { $0.isSelected }.count - requiredNumPlayers }
        
        // Throw an error if there are not enough players to make the match
        guard numSittingPlayers >= 0 else {
            throw AppErrors.notEnoughParticipants
        }
        
        if numSittingPlayers > 0 || game!.useAutoOut {
            // Sit any player that is designeted either manually or automatically to sit
            try findSittingPlayers(availableParticipants: &availableParticipants, sittingPlayers: &sittingPlayers, numSittingPlayers: numSittingPlayers)
            
            // Randomly sit remaining players and throw an error if too many players are manually set to play
            try randomSittingPlayers(availableParticipants: &availableParticipants, sittingPlayers: &sittingPlayers, numSittingPlayers: numSittingPlayers)
        }
        
        // Update player streaks and statuses and date last played
        updatePlayers(availableParticipants: &availableParticipants, sittingPlayers: &sittingPlayers)
        
        // Create the dictionary to be returned
        randomizedTeams = distributePlayers(availableParticipants: &availableParticipants, sittingPlayers: &sittingPlayers, numSittingPlayers: numSittingPlayers)
        
        // Allow the user to reroll (create a new match with the players' previous streaks and statuses
        self.canReroll = true
        saveData()
        
        return randomizedTeams
    }
    
    func rerollTeams() throws -> [String: [String: [[PlayerEntity]]]] {
        for player in self.participants {
            player.status = player.previousStatus
            player.streak = player.previousStreak
        }
        
        saveData()
        return try generateRandomTeams()
    }
    
    // Toggle if player is selected to play in the next match
    func toggleManualIn(player: PlayerEntity) {
        if requiredNumPlayers == participants.count {
            showRegAlert = true
            alertTitle = "Manual Assignment Unvailable"
            alertMessage = "Due to the number of participants and your saved match settings, all players are required to play."
        } else {
            if player.status != .manualIn {
                player.status = .manualIn
            } else {
                player.status = .none
            }
            objectWillChange.send()
            
            self.canReroll = false
            saveData()
        }
    }
    
    // Toggle if player is selected to sit out the next match
    func toggleManualOut(player: PlayerEntity) {
        if requiredNumPlayers == participants.count {
            showRegAlert = true
            alertTitle = "Manual Assignment Unvailable"
            alertMessage = "Due to the number of participants and your saved match settings, all players are required to play."
        } else {
            if player.status != .manualOut {
                player.status = .manualOut
            } else {
                player.status = .none
            }
            
            objectWillChange.send()
            
            self.canReroll = false
            saveData()
        }
    }
    
}
