//
//  BreatheVIew.swift
//  Pausepone
//
//  Created by Matsvei Liapich on 9/30/23.
//

import SwiftUI

class Breath: ObservableObject {
    @AppStorage("breaths") var breaths = 5
}

struct BreatheView: View {
    @StateObject var breath = Breath()
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
                    
                    if hour <= 12 {
                        Text("Good morning,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    }
                    else if hour <= 17 {
                        Text("Good afternoon,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    }
                    else if hour <= 21 {
                        Text("Good evening,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    } else {
                        Text("Good night,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    }
                    
                    Text("How many Breaths do you want to take?")
                        .foregroundStyle(Color.theme.foreground)
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                    
                    
                    VStack {
                        
                        HStack {
                            Spacer()
                            Text("Breaths")
                                .frame(width: 150, height: 100)
                            Picker("Select breaths", selection: breath.$breaths) {
                                ForEach(1..<61, id: \.self) { i in
                                    Text("\(i)").tag(i)
                                }
                            }
                            .frame(width: 150, height: 100)
                            .foregroundStyle(Color.theme.foreground)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                            .pickerStyle(.wheel)
                            Spacer()
                        }
                        .foregroundStyle(Color.theme.foreground)
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                        
                        NavigationLink {
                            AirView()
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color.theme.primary)
                                    .bold()
                                Text("Breathe Preset")
                                    .foregroundStyle(Color.theme.foreground)
                                    .font(.headline)
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
                        
                        
                        NavigationLink {
                            AirView()
                        } label: {
                            Text("Let's Breathe")
                                .foregroundStyle(Color.theme
                                    .background)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contentShape(Rectangle())
                            
                        }
                        .frame(height: 60)
                        .background(Color.theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                    }
                    .padding()
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                }
                .padding()
                .padding(.vertical, 100)
            }
            .ignoresSafeArea()
            
        }
        .onAppear() {
            SoundManager.instance.musicPlayer.prepareToPlay()
            SoundManager.instance.soundPlayer.prepareToPlay()
        }
    }
}

struct BreatheView_Previews: PreviewProvider {
    static var previews: some View {
        BreatheView()
    }
}


