//
//  SquadShufflerTests.swift
//  SquadShufflerTests
//
//  Created by Anthony Khera on 9/5/24.
//

import XCTest
import CoreData
@testable import SquadShuffler

final class GameViewModelTests: XCTestCase {
    
    var mockPersistentContainer: NSPersistentContainer!
    var viewModel: GameViewModel!

    override func setUpWithError() throws {
        mockPersistentContainer = NSPersistentContainer(name: "SquadShuffler")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        mockPersistentContainer.persistentStoreDescriptions = [description]
        
        mockPersistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load in-memory store \(error)")
            }
        }
        
        viewModel = GameViewModel(container: mockPersistentContainer)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockPersistentContainer = nil
    }
    
    func testInitialization() throws {
        // View model is initialized
        XCTAssertNotNil(viewModel)
        
        // Game is fetched or created
        XCTAssertNotNil(viewModel.game)
        
        // All players should be fetched
        XCTAssertNotNil(viewModel.allPlayers)
    }

    
    func testFetchAllPlayers() throws {
        let player = PlayerEntity(context: mockPersistentContainer.viewContext)
        
        player.id = UUID()
        player.playerName = "Test Player"
        player.dateLastUsed = Date()
        player.streak = 0
        player.previousStreak = 0
        player.status = .none
        player.previousStatus = .none        
        
        try mockPersistentContainer.viewContext.save()

        viewModel.fetchAllPlayers()

        // AllPlayers should contain the player
        XCTAssertEqual(viewModel.allPlayers.count, 1)
        XCTAssertEqual(viewModel.allPlayers.first?.playerName, "Test Player")
    }
    
    func testFetchGame() throws {
        viewModel.fetchGame()

        XCTAssertNotNil(viewModel.game)
        XCTAssertEqual(viewModel.game?.numGames, 1)
        XCTAssertEqual(viewModel.game?.numTeams, 2)
        XCTAssertEqual(viewModel.game?.numPlayers, 1)
    }

    func testAddPlayer_NewPlayer() throws {
        // Adding a new player
        viewModel.addPlayer(playerName: "New Player")

        // Player should be added to the context and viewmodel
        XCTAssertEqual(viewModel.allPlayers.count, 1)
        XCTAssertEqual(viewModel.allPlayers.first?.playerName, "New Player")
        XCTAssertFalse(viewModel.showPlayerExistsAlert)
    }

    func testAddPlayer_ExistingPlayer() throws {
        // Add a player
        viewModel.addPlayer(playerName: "Existing Player")

        // Add a player with the same name
        viewModel.addPlayer(playerName: "Existing Player")

        // showPlayerExistsAlert should be set to true
        XCTAssertEqual(viewModel.allPlayers.count, 1) // No new player should be added
        XCTAssertTrue(viewModel.showPlayerExistsAlert)
    }

    func testDeletePlayer() throws {
        viewModel.addPlayer(playerName: "Player to Delete")

        let playerToDelete = viewModel.allPlayers.first!
        
        viewModel.deletePlayer(player: playerToDelete)

        XCTAssertEqual(viewModel.allPlayers.count, 0)
    }
    
    func testToggleIsSelected_PlayerSelected() throws {
        // Player is added and selected
        viewModel.addPlayer(playerName: "Selectable Player")
        let player = viewModel.allPlayers.first!
        
        // Toggle selection
        viewModel.toggleIsSelected(player: player)
        
        // Test toggle
        XCTAssertTrue(player.isSelected)
        XCTAssertFalse(viewModel.canReroll)
        
        // Toggle again
        viewModel.toggleIsSelected(player: player)
        
        // Test if player was toggled back
        XCTAssertFalse(player.isSelected)
    }

    func testUpdateGameSettings() throws {
        viewModel.updateGameSettings(
            numGames: 2,
            numTeams: 3,
            numPlayers: 4,
            useAutoIn: true,
            useAutoOut: true,
            sitLimit: 2,
            playLimit: 3
        )

        XCTAssertEqual(viewModel.game?.numGames, 2)
        XCTAssertEqual(viewModel.game?.numTeams, 3)
        XCTAssertEqual(viewModel.game?.numPlayers, 4)
        XCTAssertTrue(viewModel.game!.useAutoIn)
        XCTAssertTrue(viewModel.game!.useAutoOut)
        XCTAssertEqual(viewModel.game?.sitLimit, 2)
        XCTAssertEqual(viewModel.game?.playLimit, 3)
        XCTAssertFalse(viewModel.canReroll)
    }

    func testGenerateRandomTeams() throws {
        viewModel.addPlayer(playerName: "Player 1")
        viewModel.addPlayer(playerName: "Player 2")
        viewModel.addPlayer(playerName: "Player 3")
        viewModel.addPlayer(playerName: "Player 4")
        viewModel.addPlayer(playerName: "Player 5")
        viewModel.allPlayers.forEach { $0.isSelected = true }
        
        viewModel.game?.numTeams = 2
        viewModel.game?.numPlayers = 2
        viewModel.game?.numGames = 1

        // Capture the initial dateLastUsed values before generating teams
        let initialDates = viewModel.participants.map { $0.dateLastUsed }

        // Pause to ensure any date change is detectable
        let previousDate = Date()
        Thread.sleep(forTimeInterval: 1)

        let games = try viewModel.generateRandomTeams()
        
        // Verify the generated game structure
        XCTAssertEqual(games.count, 2) // 1 for the game, 1 for sitting

        // Check that there is exactly one game and it's labeled "Game 1"
        XCTAssertNotNil(games["Game 1"])
        
        // Check that the number of teams matches the game's settings
        XCTAssertEqual(games["Game 1"]?["Teams"]?.count, Int(viewModel.game!.numTeams))

        // Check that each team has the correct number of players
        for team in games["Game 1"]!["Teams"]! {
            XCTAssertEqual(team.count, Int(viewModel.game!.numPlayers))
        }

        // Verify that no players are left unassigned (all players are either in teams or sitting)
        let totalPlayers = games["Game 1"]!["Teams"]!.flatMap { $0 }.count
        let expectedTotalPlayers = Int(viewModel.game!.numTeams * viewModel.game!.numPlayers)
        XCTAssertEqual(totalPlayers, expectedTotalPlayers, "Total players assigned to teams should match the expected number.")

        // Verify that sitting players, if any, are correctly listed
        let numSittingPlayers = viewModel.participants.count - viewModel.requiredNumPlayers
        if numSittingPlayers > 0 {
            XCTAssertNotNil(games["Sitting"]?["Sitting"])
            XCTAssertEqual(games["Sitting"]?["Sitting"]?.first?.count, numSittingPlayers)
        } else {
            XCTAssertNil(games["Sitting"])
        }

        // Verify that canReroll is set to true after team generation
        XCTAssertTrue(viewModel.canReroll)

        // Verify that participants' dateLastUsed has been updated
        let updatedDates = viewModel.participants.map { $0.dateLastUsed }

        for (index, updatedDate) in updatedDates.enumerated() {
            let initialDate = initialDates[index]
            XCTAssertNotEqual(initialDate, updatedDate)  // Verify that dateLastUsed was updated
            XCTAssertGreaterThan(updatedDate!, previousDate)  // Verify the new date is after the original check
        }

        // Verify no unexpected errors were thrown
        XCTAssertNoThrow(try viewModel.generateRandomTeams())
    }

    
    func testPlayPlayer() throws {
        // Player is added and settings are configured
        viewModel.addPlayer(playerName: "Player 1")
        let player = viewModel.allPlayers.first!
        viewModel.game?.useAutoOut = true
        viewModel.game?.playLimit = 3
        
        // Initial tests
        XCTAssertEqual(player.streak, 0)
        XCTAssertEqual(player.status, .none)
        
        // playPlayer is called multiple times
        
        // Streak should go to 1
        viewModel.playPlayer(player: player)
        XCTAssertEqual(player.streak, 1)
        XCTAssertEqual(player.status, .none)
        
        // Streak should go to 2
        viewModel.playPlayer(player: player)
        XCTAssertEqual(player.streak, 2)
        XCTAssertEqual(player.status, .none)
        
        // Streak should go to 3 and autoOut should kick in
        viewModel.playPlayer(player: player)
        XCTAssertEqual(player.streak, 3)
        XCTAssertEqual(player.status, .autoOut)
    }

    func testSitPlayer() throws {
        // Player is added and settings are configured
        viewModel.addPlayer(playerName: "Player 1")
        let player = viewModel.allPlayers.first!
        viewModel.game?.useAutoIn = true
        viewModel.game?.sitLimit = 2
        
        // Initial tests
        XCTAssertEqual(player.streak, 0)
        XCTAssertEqual(player.status, .none)
        
        // sitPlayer is called multiple times
        
        // Streak should go to -1
        viewModel.sitPlayer(player: player)
        XCTAssertEqual(player.streak, -1)
        XCTAssertEqual(player.status, .none)
        
        // Streak should go to -2 and autoIn should kick in
        viewModel.sitPlayer(player: player)
        XCTAssertEqual(player.streak, -2)
        XCTAssertEqual(player.status, .autoIn)
    }

    func testRerollTeams() throws {
        viewModel.addPlayer(playerName: "Player 1")
        viewModel.addPlayer(playerName: "Player 2")
        viewModel.addPlayer(playerName: "Player 3")
        viewModel.addPlayer(playerName: "Player 4")
        
        var players = viewModel.allPlayers
        players.forEach { $0.isSelected = true }
        
        // Store the players' status and streak
        let playerZeroOldstatus = players[0].status
        let playerZeroOldstreak = players[0].streak
        
        let playerOneOldstatus = players[1].status
        let playerOneOldstreak = players[1].streak
        
        viewModel.canReroll = true


        // Call rerollTeams to reset status and streak to previous
        let rerolledTeams = try viewModel.rerollTeams()
        
        // Check that the players' previous status and streak variables are equal to stored old values
        XCTAssertEqual(players[0].previousStatus, playerZeroOldstatus)
        XCTAssertEqual(players[0].previousStreak, playerZeroOldstreak)
        
        XCTAssertEqual(players[1].previousStatus, playerOneOldstatus)
        XCTAssertEqual(players[1].previousStreak, playerOneOldstreak)
        
        XCTAssertEqual(rerolledTeams["Game 1"]?["Teams"]?.count, Int(viewModel.game!.numTeams))
    }
    
    func testFindSittingPlayers_ThrowsTooManySittingError() throws {
        viewModel.addPlayer(playerName: "Player 1")
        viewModel.addPlayer(playerName: "Player 2")
        viewModel.addPlayer(playerName: "Player 3")
        
        var availableParticipants = viewModel.allPlayers
        var sittingPlayers: [PlayerEntity] = []
        
        // Set manualOut status for all players to simulate too many sitting
        availableParticipants.forEach { $0.status = .manualOut }

        // call findSittingPlayers with too many sitting players
        XCTAssertThrowsError(try viewModel.findSittingPlayers(
            availableParticipants: &availableParticipants,
            sittingPlayers: &sittingPlayers,
            numSittingPlayers: 2
        )) { error in
            // Error should be AppErrors.tooManySitting
            XCTAssertEqual(error as? AppErrors, AppErrors.tooManySitting)
        }
    }

    
    func testRandomSittingPlayers_ThrowsTooManyPlayingError() throws {
        viewModel.addPlayer(playerName: "Player 1")
        viewModel.addPlayer(playerName: "Player 2")
        viewModel.addPlayer(playerName: "Player 3")
        viewModel.addPlayer(playerName: "Player 4")
        
        var availableParticipants = viewModel.allPlayers
        var sittingPlayers: [PlayerEntity] = []
        
        // Set manualIn status for all players to simulate too many playing
        availableParticipants.forEach { $0.status = .manualIn }
        
        // call randomSittingPlayers with more players than allowed
        XCTAssertThrowsError(try viewModel.randomSittingPlayers(
            availableParticipants: &availableParticipants,
            sittingPlayers: &sittingPlayers,
            numSittingPlayers: 2
        )) { error in
            // Error should be AppErrors.tooManyPlaying
            XCTAssertEqual(error as? AppErrors, AppErrors.tooManyPlaying)
        }
    }
    
    func testGenerateRandomTeams_ThrowsNotEnoughParticipantsError() throws {
        // Game setting requires 4 participants
        viewModel.game?.numPlayers = 2
        viewModel.game?.numTeams = 2
        
        // Add and select only 1 player
        viewModel.addPlayer(playerName: "Player 1")
        viewModel.allPlayers.first?.isSelected = true
        
        // call generateRandomTeams with insufficient players
        XCTAssertThrowsError(try viewModel.generateRandomTeams()) { error in
            // Error should be AppErrors.notEnoughParticipants
            XCTAssertEqual(error as? AppErrors, AppErrors.notEnoughParticipants)
        }
    }


}
