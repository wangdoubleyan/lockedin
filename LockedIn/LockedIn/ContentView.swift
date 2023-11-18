//
//  ContentView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 9/30/23.
//

import SwiftUI

extension Text {

    func largeTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .font(.largeTitle)
            .bold()
    }
    
    func titleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .font(.title)
            .bold()
    }
    
    func mediumTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .font(.title2)
            .bold()
    }
    
    func smallTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .font(.title3)
            .bold()
    }
    
    func headlineTextStyle() -> some View {
        self.foregroundColor(Color.theme.secondary)
            .font(.headline)
            .bold()
    }
    
    func captionTextStyle() -> some View {
        self.foregroundColor(Color.theme.secondary)
            .font(.caption)
            .bold()
    }
}

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
