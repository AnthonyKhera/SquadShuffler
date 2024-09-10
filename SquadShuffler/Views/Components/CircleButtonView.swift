//
//  CircleButtonView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/13/23.
//

import SwiftUI

struct CircleButtonView: View {
    var iconName: String
    var diameter: CGFloat = 50
    var action: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled: Bool

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: iconName)
                .font(.system(size: diameter * 0.45))
                .foregroundColor(isEnabled ? Color(.blueApp) : Color.gray)
                .frame(width: diameter, height: diameter)
                .background(
                    Circle()
                        .foregroundColor(.white)
                )
                .shadow(color: Color(.blueApp).opacity(0.25), radius: 7)
        }
        .disabled(!isEnabled)
    }
}




#Preview {
    Group{
        CircleButtonView(iconName: "gear", diameter: 50) {
            
        }
        
        CircleButtonView(iconName: "arrow.triangle.2.circlepath") {
            
        }
    }
}


