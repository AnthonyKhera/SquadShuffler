//
//  PlayerListCell.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 2/8/24.
//

import SwiftUI

struct PlayerListCell: View {
    
    @ObservedObject var player: PlayerEntity
    
    var body: some View {
        HStack{
            Image(systemName: player.isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(player.isSelected ? Color(.blueApp) : .gray)
                .padding(.trailing, 5)
            Text(player.playerName ?? "Error loading this player.")
            Spacer()
        }
        .lineLimit(1)
        .padding(.vertical, 5)
    }
}

struct PlayerListCell_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of PersistenceController for preview purposes
        let controller = PersistenceController.preview
        
        // Create a PlayerEntity in the preview context
        let context = controller.container.viewContext
        let player = PlayerEntity(context: context)
        player.playerName = "Preview Player"
        player.isSelected = false
        
        // Return the view with the player and environment set up
        return PlayerListCell(player: player)
            .environment(\.managedObjectContext, context)
            .padding()
    }
}
