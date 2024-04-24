//
//  BreatheVIew.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 9/30/23.
//

import SwiftUI

struct BreatheView: View {
    @StateObject var breath = Breath()
    @State private var showAirView = false
    let hour = Calendar.current.component(.hour, from: Date())
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "wind")
                        Text("Take a Breath")
                            .titleTextStyle()
                    }
                    
                    Text("Select how many Breaths you want to take.")
                        .headlineTextStyle()
                        .padding(.bottom)
                    
                    
                    VStack {
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

                        .padding(.bottom, 10)
                        
                        NavigationLink {
                            AirView()
                        } label: {
                            Text("Start Breathe Session")
                                .foregroundColor(Color.theme.background)
                                .font(.title3)
                                .bold()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 60)
                        .background(Color.theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
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



