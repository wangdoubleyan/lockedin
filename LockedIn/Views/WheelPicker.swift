//
//  WheelPicker.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 7/12/24.
//

import SwiftUI

struct WheelPicker: View {
    var config: Config
    @Binding var value: Double
    @State private var isLoaded: Bool = false
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let horizontalPadding = size.width / 2
            ScrollView(.horizontal) {
                HStack(spacing: config.spacing) {
                    let totalSteps = config.steps * config.count
                    
                    ForEach(0...totalSteps, id: \.self) { index in
                        let remainder = index % config.steps
                        Rectangle()
                            .background(Color.theme.foreground)
                            .frame(width: 3, height: remainder == 0 ? 50 : 30, alignment: .top)
                            .frame(maxHeight: 60, alignment: .center)
                            .overlay(alignment: .center) {
                                if remainder == 0 && config.showsText {
                                    Text("\((index / config.steps) * config.multiplier)")
                                        .foregroundStyle(Color.theme.foreground)
                                        .headlineTextStyle()
                                        .fixedSize()
                                        .offset(y: 40)
                                }
                            }
                            .rotation3DEffect(
                                .degrees(Double((index - Int(value) * config.steps / config.multiplier)) * 2),
                                axis: (x: 1, y: 0, z: -1),
                                perspective: 0.1
                            )
                        
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? (Int(value) * config.steps) / config.multiplier : nil
                return position
            }, set: { newValue in
                if let newValue {
                    withAnimation {
                        value = (Double(newValue)) / Double(config.steps) *  Double(config.multiplier)
                    }
                }
            }))
            .safeAreaPadding(.horizontal, horizontalPadding)
            .onAppear(){
                if !isLoaded {
                    isLoaded = true
                }
            }

        }
        .mask(LinearGradient(gradient: Gradient(stops: [
            .init(color: Color.theme.background, location: 0.5),
            .init(color: .clear, location: 1), ]),startPoint: .leading, endPoint: .trailing))
        .mask(LinearGradient(gradient: Gradient(stops: [
            .init(color: Color.theme.background, location: 0.5),
            .init(color: .clear, location: 1), ]),startPoint: .trailing, endPoint: .leading))
    }
    
    struct Config: Equatable {
        var count: Int
        var steps: Int = 5
        var spacing: Double = 20
        var showsText: Bool = true
        var multiplier: Int = 10
    }
}

#Preview {
    ContentView()
}
