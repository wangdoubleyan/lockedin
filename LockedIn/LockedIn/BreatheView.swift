//
//  BreatheVIew.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 9/30/23.
//

import SwiftUI

class Breath: ObservableObject {
    @AppStorage("breaths") var breaths = 5
}

struct BreatheView: View {
    @StateObject var breath = Breath()
    @State private var showAirView = false
    let hour = Calendar.current.component(.hour, from: Date())
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack {
                    Image("Beach")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .ignoresSafeArea()
                        .mask(LinearGradient(gradient: Gradient(stops: [
                            .init(color: Color.theme.background, location: 0),
                            .init(color: .clear, location: 1), ]),
                            startPoint: .top, endPoint: .bottom))
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Text("Take a Breath")
                        .largeTitleTextStyle()
                    Text("Select how many Breaths you want to take.")
                        .headlineTextStyle()
                        .padding(.bottom)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Picker("Select breaths", selection: breath.$breaths) {
                                Text("1 breath")
                                    .titleTextStyle()
                                    .tag(1)
                                                                
                                ForEach(2..<61, id: \.self) { i in
                                    Text("\(i) breaths")
                                        .titleTextStyle()
                                        .tag(i)
                                }
                            }
                            .frame(height: 100)
                            .pickerStyle(.wheel)
                        }
                        
                        HStack(spacing: 10) {
                            NavigationLink {
                                AirView()
                            } label: {
                                HStack {
                                    Text("1 breath")
                                        .smallTitleTextStyle()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contentShape(Rectangle())
                            }
                            .frame(height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                                    .stroke(Color.theme.primary, lineWidth: 3)
                            )
                            .simultaneousGesture(TapGesture().onEnded {
                                breath.breaths = 1
                            })
                            
                            NavigationLink {
                                AirView()
                            } label: {
                                HStack {
                                    Text("5 breaths")
                                        .smallTitleTextStyle()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contentShape(Rectangle())
                            }
                            .frame(height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                                    .stroke(Color.theme.primary, lineWidth: 3)
                            )
                            .simultaneousGesture(TapGesture().onEnded {
                                breath.breaths = 5
                            })
                        }
                        
                        NavigationLink {
                            AirView()
                        } label: {
                            Text("Let's Breathe")
                                .foregroundStyle(Color.theme.background)
                                .font(.title3)
                                .bold()
                                .fontDesign(.rounded)
                                
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 60)
                        .background(Color.theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                    }
                    .padding()
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
                    Spacer()
                }
                .padding()
            }
            .ignoresSafeArea()
            
        }
        .onAppear() {
            SoundManager.instance.musicPlayer.prepareToPlay()
            SoundManager.instance.soundPlayer.prepareToPlay()
        }
    }
}

#Preview {
    BreatheView()
}



