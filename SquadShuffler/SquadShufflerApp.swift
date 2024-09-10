//
//  SquadShufflerApp.swift
//  SquadShuffler
//
//  Created by Anthony Khera on 9/5/24.
//

import SwiftUI

@main
struct SquadShufflerApp: App {
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(GameViewModel(container: persistenceController.container))
        }
    }
}
