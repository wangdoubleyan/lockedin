//
//  NavigationButton.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 7/13/24.
//

import SwiftUI

struct NavigationButton<Content: View>: View {
    private var destinationView: Content
    init(destinationView: Content) {
        self.destinationView = destinationView
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            NavigationLink {
                destinationView
            } label: {
                Text("Start")
                    .foregroundColor(Color.theme.background)
                    .font(.title3)
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 60)
            .background(Color.theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationButton(destinationView: PomodoroView())
}
