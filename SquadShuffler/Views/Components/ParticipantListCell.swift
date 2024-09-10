//
//  ParticipantListCell.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/10/23.
//

import SwiftUI

struct ParticipantListCell: View {
    @EnvironmentObject var GameViewModel: GameViewModel
    @ObservedObject var player: PlayerEntity
    
    var body: some View {
        HStack{
            Text(player.playerName ?? "Error loading this player.")
            if (player.status == .manualIn) || ((player.status == .autoIn) && GameViewModel.game!.useAutoIn) {
                Image(systemName: "chevron.up.circle.fill").foregroundColor(.green)
            } else if (player.status == .manualOut) || ((player.status == .autoOut) && GameViewModel.game!.useAutoOut) {
                Image(systemName: "chevron.down.circle.fill").foregroundColor(Color(.orangeApp))
            }
            Spacer()
            Image(systemName: "checkmark").foregroundColor(.green)
            Text("\(player.streak < 0 ? 0 : player.streak)")
            Divider().frame(height: 25)
            Image(systemName: "xmark").foregroundColor(.red)
            Text("\(player.streak > 0 ? 0 : abs(player.streak))")
        }
        .lineLimit(1)
        .padding(.vertical, 5)
        .padding(.horizontal, 25)
    }
}

struct ParticipantListCell_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let gameViewModel = GameViewModel(container: PersistenceController.preview.container)

        let newPlayer = PlayerEntity(context: context)
        newPlayer.id = UUID()
        newPlayer.playerName = "Preview Player"
        newPlayer.isSelected = false
        newPlayer.dateLastUsed = Date()
        newPlayer.streak = 2
        newPlayer.previousStreak = 0
        newPlayer.status = .autoIn
        newPlayer.previousStatus = .none

        return ParticipantListCell(player: newPlayer)
            .environment(\.managedObjectContext, context)
            .environmentObject(gameViewModel)
    }
}
