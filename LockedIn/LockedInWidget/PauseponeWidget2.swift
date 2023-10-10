//
//  PauseponeWidget2.swift
//  PauseponeWidgetExtension
//
//  Created by Matsvei Liapich on 10/9/23.
//


import WidgetKit
import SwiftUI

struct PauseponeWidget2EntryView : View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: "brain.head.profile.fill")
                    .foregroundStyle(.white)
                    .font(.title)
                Spacer()
                
                Text("Focus")
                    .font(.title)
                    .foregroundStyle(.white)
                    .fontDesign(.rounded)
                    .bold()
                
                HStack {
                    Image(systemName: "play.fill")
                    Text("25 min")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .fontDesign(.rounded)
                .bold()
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15.0, style: .continuous))
            }
            Spacer()
        }
        
        .widgetURL(URL(string: "widget://link0"))
        .widgetBackground(backgroundView: Image("Beach")
            .resizable())
    }
}



struct PauseponeWidget2: Widget {
    let kind: String = "PauseponeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PauseponeWidgetEntryView()
        }
        .configurationDisplayName("Quick Start")
        .description("Focus for 25 minutes.")
    }
}

struct PauseponeWidget2_Previews: PreviewProvider {
    static var previews: some View {
        PauseponeWidget2EntryView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
