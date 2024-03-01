//
//  FocusView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import HealthKit
import UserNotifications

struct FocusView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject var time = Time()
    @StateObject var breath = Breath()
    @StateObject var settings = Settings()
    @State private var showAirView = false
    @State private var showTimerView = false
    @State private var modes = ["Simple", "Pomodoro"]
    let hour = Calendar.current.component(.hour, from: Date())
    
    var body: some View {
        NavigationStack {
            ZStack {
//                VStack {
//                    Image("Mountain")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .ignoresSafeArea()
//                    
////                    Darkens bottom of the background
//                        .mask(LinearGradient(gradient: Gradient(stops: [
//                            .init(color: Color.theme.background, location: 0),
//                            .init(color: .clear, location: 1), ]),
//                            startPoint: .top, endPoint: .bottom))
//                    Spacer()
//                }
                
                GradientView()
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text("Time to Focus")
                        .largeTitleTextStyle()
                    
                    Text("Select how long you want to Focus for.")
                        .headlineTextStyle()
                        .padding(.bottom)
                    
                    
                    VStack {
                        if settings.selectedItem == "Simple" {
                            HStack {
                                Picker("Select hours", selection: $time.hr) {
                                    ForEach(0..<13, id: \.self) { i in
                                        Text("\(i) hr")
                                            .titleTextStyle()
                                            .tag(i)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                                
                                Picker("Select minutes", selection: $time.min) {
                                    ForEach((time.hr > 0 ? 0 : 1)..<60, id: \.self) { i in
                                        Text("\(i) min")
                                            .titleTextStyle()
                                            .tag(i)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                            }
                        } else if settings.selectedItem == "Pomodoro" {
                            HStack {
                                VStack {
                                    Text("WORK")
                                        .captionTextStyle()
                                    Picker("Select minutes", selection: $time.pomodoroWork) {
                                        ForEach(1..<60, id: \.self) { i in
                                            Text("\(i) min")
                                                .titleTextStyle()
                                                .tag(i)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 100)
                                }
                                VStack {
                                    Text("BREAK")
                                        .captionTextStyle()
                                    Picker("Select minutes", selection: $time.pomodoroBreak) {
                                        ForEach(1..<60, id: \.self) { i in
                                            Text("\(i) min")
                                                .titleTextStyle()
                                                .tag(i)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 100)
                                }
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(modes, id: \.self) { mode in
                                    if settings.selectedItem == mode {
                                        Button {
                                            withAnimation {
                                                settings.selectedItem = mode
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: settings.selectedItem == mode ? "checkmark.circle.fill" : "circle")
                                                Text(mode)
                                            }
                                            .foregroundStyle(Color.theme.background)
                                            .padding()
                                            .font(.headline)
                                        }
                                        .frame(height: 30)
                                        .background(Color.theme.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 100))
                                    } else {
                                        Button {
                                            withAnimation {
                                                settings.selectedItem = mode
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: settings.selectedItem == mode ? "checkmark.circle.fill" : "circle")
                                                Text(mode)
                                            }
                                            .foregroundStyle(Color.theme.secondary)
                                            .padding()
                                            .font(.headline)
                                        }
                                        .frame(height: 30)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 100))
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                        
                        NavigationLink {
                            TimerView()
                        } label: {
                            Text("Start Session")
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
                    .padding(.bottom, 100)
                }
                .padding()
            }
            .ignoresSafeArea()
            .navigationDestination(isPresented: $showTimerView) {
                TimerView()
            }
            .navigationDestination(isPresented: $showAirView) {
                AirView()
            }
        }
        
//        Opens screen from widget or link
        .onOpenURL { url in
            if url.absoluteString == "widget://link0" {
                time.hr = 0
                time.min = 25
                showTimerView = true
            } else if url.absoluteString == "widget://link1" {
                breath.breaths = 5
                showAirView = true
            }
        }
        
//        Reduces the lag when playing music in TimerView and AirView (maybe)
        .onAppear() {
            SoundManager.instance.musicPlayer.prepareToPlay()
            SoundManager.instance.soundPlayer.prepareToPlay()
        }
    }
}

#Preview {
    FocusView()
}

