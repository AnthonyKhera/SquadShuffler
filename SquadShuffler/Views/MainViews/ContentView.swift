//
//  ContentView.swift
//  SquadShuffler
//
//  Created by Anthony Khera on 9/5/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        TabView {
            RandomizerView()
                .tabItem {
                    Image(systemName: "shuffle")
                    Text("Teams")
                }.tag(1)
            PlayersListView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Players")
                }.tag(2)
        }
        .onAppear {
            gameViewModel.fetchAllPlayers()
        }
    }
}


//#Preview {
//    ContentView()
//        .environment(\.managedObjectContext, context)
//        .environmentObject(gameViewModel)
//}
