//
//  MindfulPauseWidget.swift
//  MindfulPauseWidget
//
//  Created by Matsvei Liapich on 9/4/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct MindfulPauseWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Pause")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .bold()
                    Text("1 min")
                        .font(.headline)
                        .foregroundStyle(Color("DullGray"))
                        .bold()
                    Spacer()
                    
                    Image(systemName: "play.fill")
                        .foregroundStyle(Color("AccentColor"))
                        .font(.largeTitle)
                }
                Spacer()
            }
            .padding(5)
            ZStack {
                Circle()
                    .stroke(lineWidth: 40)
                    .foregroundStyle(Color("DullGray"))
                    .opacity(0.2)
                
                Circle()
                    .trim(from: 0.0, to: min(0.8, 1.0))
                    .stroke(Color("Fawn"), style: StrokeStyle(lineWidth: 25.0, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270))
            }
            .offset(x: 70, y: 70)
        }
        .widgetURL(URL(string: "widget://link0"))
    }
}

struct MindfulPauseWidget: Widget {
    let kind: String = "MindfulPauseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MindfulPauseWidgetEntryView(entry: entry)
                    .containerBackground(Color("WidgetBackground"), for: .widget)
            } else {
                MindfulPauseWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Quick Start")
        .description("Automatically starts a 1 minute Pause.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    MindfulPauseWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
