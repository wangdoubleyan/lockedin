//
//  TimerView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

struct TimerView: View {
    @State var hr: Int = 1
    @State var min: Int = 0
    @State var progress = 0.0
    @State var timeRemaining = 0
    
    var totalTime: Double {
        Double(hr * 60 * 60 + min * 60)
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 30)
                .foregroundStyle(.gray)
                .opacity(0.1)
            
            Circle()
                .trim(from: 0.0, to: Swift.min(progress, 1.0))
                .stroke(Color.blue.opacity(0.2), style: StrokeStyle(lineWidth: 25.0, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear(duration: 1), value: progress)
            
            VStack(spacing: 5) {
                Text("\(printFormattedTime(timeRemaining))")
                    .font(.title)
                    .bold()
                    .fontDesign(.rounded)
            }
            .padding()
    
        }
        .frame(width: 275, height: 275)
        .padding()
        .onAppear {
            calculateTimeRemaining(hours: hr, minutes: min)
        }
        .onReceive(timer) { time in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress += 1.0 / totalTime
            }
        }
    }
    
    
    func calculateTimeRemaining(hours: Int, minutes: Int) -> Int {
        timeRemaining = hours * 60 * 60 + minutes * 60
        return timeRemaining
    }
        
    func formatTime(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func printFormattedTime(_ seconds: Int) -> String {
        let (h, m, s) = formatTime(seconds)
        if h > 0 && m < 1 && s < 1 {
            return "\(h) hr"
        } else if h > 0 && m < 1 {
            return "\(h) hr \(s) sec"
        } else if h > 0 && s < 1 {
            return "\(h) hr \(m) min"
        } else if h > 0 {
            return "\(h) hr \(m) min \(s) sec"
        } else if m > 0 && s < 1 {
            return "\(m) min"
        } else if m > 0 {
            return "\(m) min \(s) sec"
        } else {
            return "\(s) sec"
        }
       
    }
}

#Preview {
    TimerView()
}
