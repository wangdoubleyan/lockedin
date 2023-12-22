//
//  ContentView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 9/30/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TabView {
                FocusView()
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Focus")
                            .captionTextStyle()
                    }
                BreatheView()
                    .tabItem {
                        Image(systemName: "wind")
                        Text("Breathe")
                            .captionTextStyle()
                    }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Text(Image(systemName: "gear.circle.fill"))
                            .font(.system(size: 35))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
