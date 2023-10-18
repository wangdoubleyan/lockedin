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
            .fontDesign(.rounded)
    }
    
    func titleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .font(.title)
            .bold()
            .fontDesign(.rounded)
    }
    
    func mediumTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .font(.title2)
            .bold()
            .fontDesign(.rounded)
    }
    
    func smallTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .font(.title3)
            .bold()
            .fontDesign(.rounded)
    }
    
    func headlineTextStyle() -> some View {
        self.foregroundColor(Color.theme.secondary)
            .font(.headline)
            .bold()
            .fontDesign(.rounded)
    }
    
    func captionTextStyle() -> some View {
        self.foregroundColor(Color.theme.secondary)
            .font(.caption)
            .bold()
            .fontDesign(.rounded)
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
