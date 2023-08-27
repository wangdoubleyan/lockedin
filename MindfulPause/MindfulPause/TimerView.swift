//
//  TimerView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var time: Time
    @State private var progress = 0.0
    @State private var timeRemaining = 0
    @State private var stroke = 0.0
    @State private var opacity = 0.0
        
    var totalTime: Double {
        Double(time.hr * 60 * 60 + time.min * 60)
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: stroke)
                .foregroundStyle(.gray)
                .opacity(0.1)
                .animation(.smooth(duration: 3), value: stroke)
            
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(Color.blue.opacity(opacity), style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270))
                .animation(.smooth(duration: 3), value: opacity)
                .animation(.linear(duration: 1), value: progress)
                
                
            
            
            VStack {
                Text("\(printFormattedTime(timeRemaining))")
                    .font(.largeTitle)
                    .bold()
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .transition(.slide)
            }
            .onChange(of: timeRemaining, initial: true) { oldValue, newValue in
                if Double(newValue) == 0 {
                    snapBack()
                } else if Double(newValue) == totalTime / 4 || Double(newValue) == totalTime / 2 || Double(newValue) == totalTime / 4 * 3 {
                    snapBack()
                }
            }
        }
        .padding(80)
        .onAppear {
            if time.hr == 0 && time.min == 0 {
                time.min = 1
            }
            calculateTimeRemaining(hours: time.hr, minutes: time.min)
            stroke = 40.0
            opacity = 0.2
        }
        .onReceive(timer) { time in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress += 1.0 / totalTime
            }
        }
        
    }
    
    
    func calculateTimeRemaining(hours: Int, minutes: Int) {
        timeRemaining = hours * 60 * 60 + minutes * 60
    }
        
    func formatTime(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func printFormattedTime(_ seconds: Int) -> String {
        let (h, m, s) = formatTime(seconds)
        
        if h > 0 && m < 1 && s < 1 {
            return "\(h) hr"
        } else if h > 0 && m < 1 {
            return """
                    \(h) hr
                    \(s) sec
                    """
        } else if h > 0 && s < 1 {
            return """
                    \(h) hr
                    \(m) min
                    """
        } else if h > 0 {
            return """
                    \(h) hr
                    \(m) min
                    \(s) sec
                    """
        } else if m > 0 && s < 1 {
            return """
                    \(m) min
                    """
        } else if m > 0 {
            return """
                    \(m) min
                    \(s) sec
                    """
        } else {
            return """
                    \(s) sec
                    """
        }
    }
    
    func snapBack() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

}
    
#Preview {
    TimerView(time: Time())
}
