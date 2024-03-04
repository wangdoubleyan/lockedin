//
//  ContentView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 9/30/23.
//

import SwiftUI

struct ContentView: View {
    @State private var logo = "StartLogo"
    var body: some View {
        
        
        NavigationStack {
            ZStack {
                GradientView()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    FocusView()
                    BreatheView()
                        .padding(.bottom, 100)
                }
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color.theme.background, location: 0.8),
                    .init(color: .clear, location: 1), ]),startPoint: .top, endPoint: .bottom))
            }
            .navigationTitle("LockedIn")
//            TabView {
                
//                FocusView()
//                    .tabItem {
//                        Image(systemName: "brain.head.profile")
//                        Text("Focus")
//                            .captionTextStyle()
//                    }
//                BreatheView()
//                    .tabItem {
//                        Image(systemName: "wind")
//                        Text("Breathe")
//                            .captionTextStyle()
//                    }
//            }
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
    ContentView()
}
