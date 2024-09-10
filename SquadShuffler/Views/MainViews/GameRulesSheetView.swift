//
//  GameRulesSheetView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 11/10/23.
//

import SwiftUI

struct GameRulesSheetView: View {
    
    @EnvironmentObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Temporary variables to store changes
    @State var updatedNumGames: Int32
    @State var updatedNumTeams: Int32
    @State var updatedNumPlayers: Int32
    @State var updatedUseAutoIn: Bool
    @State var updatedUseAutoOut: Bool
    @State var updatedSitLimit: Int32
    @State var updatedPlayLimit: Int32
    
    // TODO: Create alerts if number of sit/play limit is not appropriate for the number of people
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("Match Details"), footer: Text("This represents the number of games played at the same time, the number of teams for each game, and the number of players on each team.")){
                    Stepper("Games: \(updatedNumGames)", value: $updatedNumGames, in: 1...50)
                    Stepper("Teams per Game: \(updatedNumTeams)", value: $updatedNumTeams, in: 2...50)
                    Stepper("Players on Team: \(updatedNumPlayers)", value: $updatedNumPlayers, in: 1...50)
                }
                
                
                Section(header: Text("Streak Limits"), footer: Text("Use streak limits to help make sure everyone gets to paricipate. When in use, the matchmaking algorithm will automatically sit/play anyone that has reached the set limit. \n\nOnly one Streak Limit can be set at a time.")){
                    
                    Toggle(isOn: $updatedUseAutoIn.animation(), label: {
                        Text("Limit Consecutive Sits")
                    })
                    .onChange(of: updatedUseAutoIn, perform: { value in
                        withAnimation {
                            if updatedUseAutoIn {
                                if updatedUseAutoOut { updatedUseAutoOut.toggle() }
                            }
                        }
                    })
                    
                    if updatedUseAutoIn {
                        Stepper("Sit Limit: \(updatedSitLimit)", value: $updatedSitLimit, in: 1...50)
                    }
                    
                    Toggle(isOn: $updatedUseAutoOut.animation(), label: {
                        Text("Limit Consecutive Plays")
                    })                    
                    .onChange(of: updatedUseAutoOut, perform: { value in
                        withAnimation{
                            if updatedUseAutoOut {
                                if updatedUseAutoIn { updatedUseAutoIn.toggle() }
                            }
                        }
                    })
                    
                    if updatedUseAutoOut {
                        Stepper("Play Limit: \(updatedPlayLimit)", value: $updatedPlayLimit, in: 1...50)
                    }
                }
                
                Section{
                    Button(action: {
                        gameViewModel.updateGameSettings(
                            numGames: updatedNumGames,
                            numTeams: updatedNumTeams,
                            numPlayers: updatedNumPlayers,
                            useAutoIn: updatedUseAutoIn,
                            useAutoOut: updatedUseAutoOut,
                            sitLimit: updatedSitLimit,
                            playLimit: updatedPlayLimit
                        )
                        dismiss()
                    }, label: {
                        Text("Save")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .foregroundColor(.white)
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Match Settings")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
    }
}


struct GameRulesSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let gameViewModel = GameViewModel(container: PersistenceController.preview.container)
        
        // Create a preview instance of the GameRulesSheetView
        GameRulesSheetView(
            updatedNumGames: gameViewModel.game?.numGames ?? 1,
            updatedNumTeams: gameViewModel.game?.numTeams ?? 2,
            updatedNumPlayers: gameViewModel.game?.numPlayers ?? 1,
            updatedUseAutoIn: false,
            updatedUseAutoOut: false,
            updatedSitLimit: gameViewModel.game?.sitLimit ?? 2,
            updatedPlayLimit: gameViewModel.game?.playLimit ?? 2
        )
        .environment(\.managedObjectContext, context)
        .environmentObject(gameViewModel)
    }
}


