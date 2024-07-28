//
//  ContentView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 9/30/23.
//

import SwiftUI

struct HomeView: View {
    @State private var logo = "StartLogo"
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                ScrollView(showsIndicators: false) {
                    PomodoroView()
                    BreatheView()
                }
            }

            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Text(Image(systemName: "gearshape.circle.fill"))
                            .font(.system(size: 35))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image(logo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70)
                        .offset(y: 15)
                        .contentTransition(.numericText())
                        .onAppear {
                            withAnimation(.snappy(duration: 5)) {
                                    logo = "FinishLogo"
                                }
                        }
                }
            }
        }
        
    }
}

#Preview {
    HomeView()
}
