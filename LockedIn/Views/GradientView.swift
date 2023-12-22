//
//  GradientView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 11/27/23.
//

import SwiftUI


struct GradientView: View {
    @State var start = UnitPoint(x: 0, y: -2)
    @State var end = UnitPoint(x: 4, y: 0)

    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colors = [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)), Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1))]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .animation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true).speed(0.5), value: end)
            .onReceive(timer, perform: { _ in
                self.start = UnitPoint(x: 4, y: 0)
                self.end = UnitPoint(x: 0, y: 2)
                self.start = UnitPoint(x: -4, y: 20)
                self.start = UnitPoint(x: 4, y: 0)
            })
    }
}

#Preview {
    GradientView()
}
