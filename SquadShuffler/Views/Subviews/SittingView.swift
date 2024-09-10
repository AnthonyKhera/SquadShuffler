//
//  SittingView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/12/23.
//

import SwiftUI

struct SittingView: View {
    let players: [PlayerEntity]
    let width: CGFloat = .infinity
    
    var body: some View {
        VStack{
            Text("Sitting")
                .foregroundColor(.white)
                .bold()
                .background(Capsule()
                    .fill(Color(.orangeApp))
                    .frame(width: 100, height: 25))
            VStack{
                ForEach(players, id:\.playerName) { player in
                    Text(player.playerName ?? "Error retrieving player")
                        .font(.body)
                        .foregroundColor(.black)
                        .lineLimit(1)
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
                .shadow(color: .gray.opacity(0.35), radius: 10))
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct SittingView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = PersistenceController.preview
        let context = controller.container.viewContext
        
        let player1 = PlayerEntity(context: context)
        player1.playerName = "Player One"
        
        let player2 = PlayerEntity(context: context)
        player2.playerName = "Player Two"
        
        let player3 = PlayerEntity(context: context)
        player3.playerName = "Player Three"
        
        let players = [player1, player2, player3]
        
        return SittingView(players: players)
            .environment(\.managedObjectContext, context)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}


