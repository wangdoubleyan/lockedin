//
//  PomodoroView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import HealthKit
import UserNotifications

struct PomodoroView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject var time = Time()
    @StateObject var breath = Breath()
    @StateObject var settings = Settings()
    @State private var showAirView = false
    @State private var showTimerView = false
    @State private var modes = ["Simple", "Pomodoro"]
    @State private var config: WheelPicker.Config = .init(count: 18, multiplier: 5)
    let hour = Calendar.current.component(.hour, from: Date())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "timer")
                Text("Pomodoro Focus")
                    .titleTextStyle()
            }
            .padding(.top)
            
            Text("Select Pomodoro interval length.")
                .headlineTextStyle()
                .padding(.bottom)
            
            ZStack {
                Image("tomato")
                    .resizable()
                    .fixedSize()
                    .scaleEffect(1.2, anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .offset(y: -25)
                
                VStack(spacing: 0) {
                    Text(verbatim: time.min == 0 ? "∞" : "\(Int(time.min))")
                        .largeTitleTextStyle()
                        .contentTransition(.numericText(value: time.min))
                        .animation(.snappy, value: time.min)
                        .padding(.top, 120)
                    
                    Text("minutes")
                        .smallTitleTextStyle()
                        .padding(.bottom, 10)
                    
                    Triangle()
                        .rotation(.degrees(180))
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.theme.foreground)
                    
                    WheelPicker(config: config, value: $time.min)
                        .frame(width: 200, height: 160)
                    
                    NavigationButton(destinationView: PomodoroTimerView())
                        .padding(.top)
                    
                }
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
        }
        .padding()
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
    }
}

#Preview {
    HomeView()
}

