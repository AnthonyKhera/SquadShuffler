//
//  ToolBarMenuItem.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 2/9/24.
//

import SwiftUI

struct ToolBarMenuItem: View {
    var body: some View {
        Button{
            print("Menu tapped")
        } label: {
            Image(systemName: "line.3.horizontal")
        }
        .font(.system(size: 28))    }
}

struct DropDownMenuItem: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        Menu {
             Button(action: {
                 gameViewModel.resetAllParticipants()
             }) {
                 Label("Reset All", systemImage: "arrow.triangle.2.circlepath")
             }
             
             Button(action: {
                 gameViewModel.removeAllParticipants()
             }) {
                 Label("Remove All", systemImage: "minus.circle")
             }
             
         } label: {
             Image(systemName: "ellipsis")
                 .font(.system(size: 28))
                 .frame(width: 60, height: 45)
         }
    }
}

#Preview {
    DropDownMenuItem()
}
