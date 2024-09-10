//
//  SplashScreenView.swift
//  SquadShuffler
//
//

import SwiftUI

struct SplashScreenView: View {
    @State private var showSplash = true
    var body: some View {
        
        if showSplash {
            VStack {
                VStack {
                    Image("SquadShuffleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding(.bottom, -35)
                    Text("Squad Shuffle")
                        .font(Font.custom("HelveticaNeue", size: 35))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)

                .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(colors: [Color(#colorLiteral(red: 0.006257305836, green: 9.125278776e-05, blue: 0.1564168146, alpha: 1)), Color(.blueApp)], startPoint: .leading, endPoint: .trailing))
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        self.showSplash = false
                    }
                }
            }
        } else {
            ContentView()
        }
    }
}

#Preview {
    SplashScreenView()
}
