//
//  PrimaryButtonView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/13/23.
//

import SwiftUI

struct PrimaryButtonView: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(RoundedRectangle(cornerRadius: 7)
                    .fill(Color(.blueApp)))
                .shadow(color: Color(.blueApp).opacity(0.25), radius: 7)
        }
    }
}

