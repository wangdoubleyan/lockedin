//
//  FocusView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import HealthKit
import UserNotifications

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

class Time: ObservableObject {
    @AppStorage("hr") var hr = 0
    @AppStorage("min") var min = 1
    @AppStorage("pomodoroWork") var pomodoroWork = 25
    @AppStorage("pomodoroBreak") var pomodoroBreak = 5
}

class Review: ObservableObject {
    @AppStorage("cycleCount") var cycleCount = 0
}

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
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack {
                    
                    Image("Stream")
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
                                        ForEach((time.pomodoroWork > 0 ? 0 : 1)..<60, id: \.self) { i in
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
                                        ForEach((time.pomodoroBreak > 0 ? 0 : 1)..<60, id: \.self) { i in
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
                                    Button {
                                        withAnimation {
                                            settings.selectedItem = mode
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: settings.selectedItem == mode ? "checkmark.circle.fill" : "circle")
                                            Text(mode)
                                        }
                                        .foregroundStyle(settings.selectedItem == mode ? Color.theme.background : Color.theme.secondary)
                                        .padding()
                                        .font(.headline)
                                    }
                                    .frame(height: 30)
                                    .background(settings.selectedItem == mode ? Color.theme.primary : Color.theme.sky)
                                    .clipShape(RoundedRectangle(cornerRadius: 100))
                                }
                            }
                        }

                        .padding(.bottom, 10)
                        
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
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
                    Spacer()
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
        .onAppear() {
            SoundManager.instance.musicPlayer.prepareToPlay()
            SoundManager.instance.soundPlayer.prepareToPlay()
        }
    }
}

#Preview {
    FocusView()
}

