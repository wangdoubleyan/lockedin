//
//  SelectView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

struct SelectView: View {
    @State var hr: Int = 0
    @State var min: Int = 5
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("How long do you want to pause?")
                    .font(.title)
                    .fontDesign(.rounded)
                    .bold()
                
                HStack {
                    Picker("", selection: $hr) {
                        ForEach(0..<6, id: \.self) { i in
                            Text("\(i) hr").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    Picker("", selection: $min) {
                        ForEach(0..<60, id: \.self) { i in
                            Text("\(i) min").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding()
                
                NavigationLink {
                    TimerView()
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
