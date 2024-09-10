//
//  RandomizerResultsView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/6/23.
//

import SwiftUI

struct GameStackView: View {
    
    let teams:[[PlayerEntity]]
    let game: String
    
    var body: some View {
        VStack{
            ZStack {
                Capsule()
                    .fill(Color(.blueApp))
                    .frame(width: 100, height: 25)
                Text(game)
                    .foregroundColor(.white)
                    .bold()
            }
            
            ZStack {
                VStack {
                    if teams.count > 4 {
                        ForEach(teams.indices, id: \.self){ index in
                            TeamCell(players: teams[index], width: .infinity, height: 20)
                            if index != teams.count-1 {
                                VsCircleView()
                                    .padding(.vertical, -10)
                                    .zIndex(2)
                            }
                        }
                    } else {
                        ForEach(0..<teams.count/2, id: \.self) { index in
                            HStack {
                                TeamCell(players: teams[index * 2], width: .infinity)
                                TeamCell(players: teams[index * 2 + 1], width: .infinity)
                            }
                        }
                        
                        if teams.count % 2 != 0 {
                            TeamCell(players: teams[teams.count - 1], width: .infinity)
                        }
                    }
                }
                if teams.count < 5 {VsCircleView()}
            }
        }
        .padding(.horizontal)
    }
}

struct GameStackView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = PersistenceController.preview
        let context = controller.container.viewContext
        
        let player1 = PlayerEntity(context: context)
        player1.playerName = "Player One"
        
        let player2 = PlayerEntity(context: context)
        player2.playerName = "Player Two"
        
        let player3 = PlayerEntity(context: context)
        player3.playerName = "Player Three"
        
        let player4 = PlayerEntity(context: context)
        player4.playerName = "Player Four"
        
        let player5 = PlayerEntity(context: context)
        player5.playerName = "Player Five"
        
        let player6 = PlayerEntity(context: context)
        player6.playerName = "Player Six"
        
        let teams: [[PlayerEntity]] = [
            [player1, player2],
            [player3, player4],
            [player3, player4],
            [player3, player4]
        ]
        
        // Return the view with the sample teams and game name
        return GameStackView(teams: teams, game: "Game 1")
            .environment(\.managedObjectContext, context)
            .previewLayout(.sizeThatFits)
    }
}



