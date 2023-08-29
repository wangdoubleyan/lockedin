//
//  SelectView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

class Time: ObservableObject {
    @AppStorage("hr") var hr = 0
    @AppStorage("min") var min = 1
}

struct SelectView: View {
    @StateObject var time = Time()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    Spacer()
                    Spacer()
                    
                    Text("Hello, friend!")
                        .foregroundStyle(Color.theme.secondary)
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                    
                    Text("How long do you want to Pause?")
                        .foregroundStyle(Color.theme.foreground)
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                    
                    Spacer()
                    
                    HStack {
                        Picker("Select hours", selection: $time.hr) {
                            ForEach(0..<13, id: \.self) { i in
                                Text("\(i) hr").tag(i)
                                    .foregroundStyle(Color.theme.secondary)
                                    .font(.title)
                                    .fontDesign(.rounded)
                                    .bold()
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Select minutes", selection: $time.min) {
                            ForEach((time.hr > 0 ? 0 : 1)..<60, id: \.self) { i in
                                Text("\(i) min").tag(i)
                                    .foregroundStyle(Color.theme.secondary)
                                    .font(.title)
                                    .fontDesign(.rounded)
                                    .bold()
                                                                }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding(-10)
                    
                    Spacer()
                    

                    NavigationLink {
                        TimerView(time: time, settings: Settings())
                    } label: {
                        Text("Let's Pause")
                            .foregroundStyle(Color.theme.foreground)
                            .fontDesign(.rounded)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .contentShape(Rectangle())
                            .padding(.vertical)
                        
                    }
                    .background(Color.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                    

                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 25)
                }
            }
        }
    }
}

#Preview {
    SelectView()
}
