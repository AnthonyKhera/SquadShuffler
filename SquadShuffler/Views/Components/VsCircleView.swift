//
//  VsCircleView.swift
//  Squad Shuffle
//
//  Created by Anthony Khera on 10/13/23.
//

import SwiftUI

struct VsCircleView: View {
    var body: some View {
        Text("Vs")
            .foregroundColor(.white)
            .bold()
            .background(
                Circle()
                    .fill(.black)
                    .frame(width: 30, height: 30))
    }
}

#Preview {
    VsCircleView()
}
