//
//  TeamCell.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/5/23.
//

import SwiftUI

struct TeamCell: View {
    
    init(players: [PlayerEntity], shadowColor: Color = .gray, width: CGFloat = 145, height: CGFloat = 45) {
        self.players = players
        self.shadowColor = shadowColor
        self.width = width
        self.height = height
    }
    
    
    let players: [PlayerEntity]
    let shadowColor: Color
    let width: CGFloat
    let height: CGFloat

    var body: some View {
            VStack{
                ForEach(players, id:\.playerName) { player in
                    Text(player.playerName ?? "Error loading this player")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(height: height)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .animation(nil)
                    if player != players.last {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: width, alignment: .center)
            .padding()
            .background(RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.white)
                .shadow(color: shadowColor.opacity(0.35), radius: 10))
    }
}

struct TeamCell_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of PersistenceController for preview purposes
        let controller = PersistenceController.preview
        
        // Create multiple PlayerEntity instances in the preview context
        let context = controller.container.viewContext
        
        let player1 = PlayerEntity(context: context)
        player1.playerName = "Player One"
        
        let player2 = PlayerEntity(context: context)
        player2.playerName = "Player Two"
        
        let player3 = PlayerEntity(context: context)
        player3.playerName = "Player Three"
        
        // Create an array of PlayerEntity instances
        let players = [player1, player2, player3]
        
        // Return the view with the sample players and environment set up
        return TeamCell(players: players)
            .environment(\.managedObjectContext, context)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

