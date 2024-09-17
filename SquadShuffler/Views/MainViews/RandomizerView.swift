//
//  RandomizerView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/12/23.
//

import SwiftUI

struct RandomizerView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    
    
    @State var randomData: [String: [String: [[PlayerEntity]]]] = [:]
    @State private var isContentVisible = true
    @State private var isSettingsSheetPresented = false
    @State private var appError: AppErrors = .tooManyPlaying
    
    var body: some View {
        VStack {
            
            VStack {
                HStack {
                    Spacer()
                    VStack{
                        Text("Matchmaking")
                            .font(.title)
                            .bold()
                            .foregroundStyle(.black)
                        Text("Squad Shuffle")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack{
                    
                    CircleButtonView(iconName: "arrow.triangle.2.circlepath") {
                        withAnimation(.easeIn(duration: 0.25)) {isContentVisible = false}
                        
                        do {
                            try randomData = gameViewModel.rerollTeams()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeOut(duration: 0.25)) {isContentVisible = true}
                            }
                        } catch let caughtError as AppErrors {
                            gameViewModel.showErrorAlert = true
                            appError = caughtError
                        } catch {
                            gameViewModel.showErrorAlert = true
                            appError = .defaultError(error)
                        }
                        
                    }
                    .disabled(!gameViewModel.canReroll)
                    
                    Spacer()
                    
                    PrimaryButtonView(title: "Build Games", action: {
                        withAnimation(.easeIn(duration: 0.25)) {isContentVisible = false}
                        
                        do {
                            try randomData = gameViewModel.generateRandomTeams()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeOut(duration: 0.25)) {isContentVisible = true}
                            }
                        } catch let caughtError as AppErrors {
                            gameViewModel.showErrorAlert = true
                            appError = caughtError
                        } catch {
                            gameViewModel.showErrorAlert = true
                            appError = .defaultError(error)
                        }
                        
                        
                        
                    })
                    .padding()
                    .alert(isPresented: $gameViewModel.showErrorAlert, error: appError) { error in } message: { error in
                        Text(error.failureReason)
                    }
                    .alert(gameViewModel.alertTitle, isPresented: $gameViewModel.showRegAlert) {
                        
                    } message: {
                        Text(gameViewModel.alertMessage)
                    }
                    
                    Spacer()
                    CircleButtonView(iconName: "gear") {
                        withAnimation {
                            isSettingsSheetPresented.toggle()
                        }
                    }
                    .sheet(isPresented: $isSettingsSheetPresented) {
                        GameRulesSheetView(
                            updatedNumGames: gameViewModel.game!.numGames,
                            updatedNumTeams: gameViewModel.game!.numTeams,
                            updatedNumPlayers: gameViewModel.game!.numPlayers,
                            updatedUseAutoIn: gameViewModel.game!.useAutoIn,
                            updatedUseAutoOut: gameViewModel.game!.useAutoOut,
                            updatedSitLimit: gameViewModel.game!.sitLimit,
                            updatedPlayLimit: gameViewModel.game!.playLimit)
                    }
                    
                }
                .padding(.horizontal, 30)
                .background(Color(.white))
            }
            .background(.white)
            Divider()
            
            
            
            List {
                Section {
                    if isContentVisible {
                        ForEach(randomData.keys.sorted(), id: \.self) { gameKey in
                            if let gameInfo = randomData[gameKey], let teams = gameInfo["Teams"] {
                                GameStackView(teams: teams, game: gameKey)
                            }
                        }
                        if let sittingPlayers = randomData["Sitting"]?["Sitting"]?[0] {
                            SittingView(players: sittingPlayers)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                
                Section(header:
                            HStack {
                    DropDownMenuItem()
                        .padding(.leading, 25)
                        .disabled(true)
                        .hidden()
                    
                    Spacer()
                    Text("Participants")
                        .font(.title3)
                        .bold()
                    Spacer()
                    
                    DropDownMenuItem()
                        .padding(.trailing, 25)
                    
                }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.leading, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.blueApp))
                    .padding(.top, -26)
                    .padding(.horizontal, -20)
                    .padding(.bottom, -5)
                )
                {
                    if gameViewModel.participants.isEmpty {
                        ContentUnavailableView("No Participants", systemImage: "person.2.slash.fill", description: Text("Select the players you would like to particpate today."))
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(gameViewModel.participants, id: \.id) { player in
                            ParticipantListCell(player: player)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let index = gameViewModel.participants.firstIndex(of: player) {
                                            gameViewModel.removeParticipant(indexSet: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Text("Remove")
                                    }
                                    .tint(.red)
                                    
                                    Button{
                                        player.resetPlayer(isSelected: true)
                                    } label: {
                                        Text("Reset")
                                    }
                                    .tint(Color.yellow)
                                }
                            
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        gameViewModel.toggleManualOut(player: player)
                                    } label: {
                                        Text(player.status == .manualOut ? "Undo" : "Sit Next")
                                    }
                                    .tint(player.status == .manualOut ? Color.blue : Color(.orangeApp))
                                    
                                    Button {
                                        gameViewModel.toggleManualIn(player: player)
                                    } label: {
                                        Text(player.status == .manualIn ? "Undo" : "Play Next")
                                    }
                                    .tint(player.status == .manualIn ? Color.blue : Color.green)
                                    
                                }
                        }
                    }
                }
                .padding(.leading, -8)
                .background(Color(.white))
            }
            .listStyle(.inset)
            .padding(.vertical, -8)
            .padding(.bottom, 5)
            .background(Color(.grayBack))
        }
    }
}

struct RandomizerView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let gameViewModel = GameViewModel(container: PersistenceController.preview.container)
        
        // Create a preview instance of the GameRulesSheetView
        RandomizerView()
            .environment(\.managedObjectContext, context)
            .environmentObject(gameViewModel)
    }
}
