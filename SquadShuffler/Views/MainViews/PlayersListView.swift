//
//  PlayersListView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 2/8/24.
//

import SwiftUI

struct PlayersListView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @State var newPlayerName: String = ""
    
    var body: some View {
        VStack {
            
            Text("Player Selection")
                .font(.title)
                .bold()
                .foregroundStyle(.black)
            Text("Squad Shuffle")
                .font(.subheadline)
                .foregroundStyle(.black)
            
                .alert(isPresented: $gameViewModel.showPlayerExistsAlert) {
                    Alert(
                        title: Text("Player Already Added"),
                        message: Text("A player of that name already exists. Please use another name."),
                        dismissButton: .default(Text("OK")) {
                            gameViewModel.showPlayerExistsAlert = false
                        }
                    )
                }
            
            List {
                Section(header: Text("Add New Player")) {
                    HStack {
                        TextField("New player name", text: $newPlayerName)
                            .onSubmit {
                                addNewPlayer()
                            }
                        
                        Button(action: {
                            addNewPlayer()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
                Section(header: Text("Participating Players")) {
                    ForEach(gameViewModel.participants, id: \.id) { player in
                        PlayerListCell(player: player)
                            .onTapGesture {
                                withAnimation(.linear(duration: 0.15)) {
                                    gameViewModel.toggleIsSelected(player: player)
                                }
                            }
                    }
                }
                Section(header: Text("Remaining Players")) {
                    if gameViewModel.allPlayers.isEmpty {
                        ContentUnavailableView("No Players", systemImage: "person.slash.fill", description: Text("Add some players to get started."))
                    } else {
                        ForEach(gameViewModel.allPlayers.filter { !$0.isSelected }, id: \.id) { player in
                            PlayerListCell(player: player)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.15)) {
                                        gameViewModel.toggleIsSelected(player: player)
                                    }
                                }
                        }
                        .onDelete(perform: deletePlayer)
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
    
    private func addNewPlayer() {
        if newPlayerName != "" {
            withAnimation {
                gameViewModel.addPlayer(playerName: newPlayerName)
                newPlayerName = ""
            }
        }
    }
    
    private func deletePlayer(indexSet: IndexSet) {
        let filteredPlayers = gameViewModel.allPlayers.filter { !$0.isSelected }
        
        for index in indexSet {
            guard index < filteredPlayers.count else { continue }
            
            let playerToDelete = filteredPlayers[index]
            
            if let originalIndex = gameViewModel.allPlayers.firstIndex(where: { $0.id == playerToDelete.id }) {
                gameViewModel.deletePlayer(player: gameViewModel.allPlayers[originalIndex])
            }
        }
    }

    
}

struct PlayersListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let gameViewModel = GameViewModel(container: PersistenceController.preview.container)
        
        // Create a preview instance of the GameRulesSheetView
        PlayersListView()
            .environment(\.managedObjectContext, context)
            .environmentObject(gameViewModel)
    }
}



