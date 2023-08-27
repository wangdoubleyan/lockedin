//
//  SelectView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

class Time: ObservableObject {
    @Published var hr = 0
    @Published var min = 1
}

struct SelectView: View {
    @StateObject var time = Time()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("How long do you want to pause?")
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                                    
                HStack(spacing: 0) {
                    Picker("Select hours", selection: $time.hr) {
                        ForEach(0..<13, id: \.self) { i in
                            Text("\(i) hr").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Select minutes", selection: $time.min) {
                        ForEach((time.hr > 0 ? 0 : 1)..<60, id: \.self) { i in
                            Text("\(i) min").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                NavigationLink {
                    TimerView(time: time)
                } label: {
                    Text("Let's Pause")
                        .fontDesign(.rounded)
                        .font(.headline)
                        .bold()
                }
                .padding(20)
                .background(.blue.opacity(0.2))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding()
        }
    }
}

#Preview {
    SelectView()
}
