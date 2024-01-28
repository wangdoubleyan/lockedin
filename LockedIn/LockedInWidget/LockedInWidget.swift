//
//  LockedInWidget.swift
//  LockedInWidget
//
//  Created by Matsvei Liapich on 10/9/23.
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

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct LockedInWidgetEntryView : View {
    var entry: Provider.Entry

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
                    .bold()
                
                HStack {
                    Image(systemName: "play.fill")
                    Text("25 min")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .bold()
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15.0, style: .continuous))
            }
            Spacer()
        }
        .widgetBackground(backgroundView: Image("Stream").resizable().aspectRatio(contentMode: .fill))
        .widgetURL(URL(string: "widget://link0"))
    }
}

struct LockedInWidgetEntry2View : View {
    var entry: Provider.Entry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: "wind")
                    .foregroundStyle(.white)
                    .font(.title)
                Spacer()
                
                Text("Breathe")
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
                
                HStack {
                    Image(systemName: "lungs.fill")
                    Text("5 breaths")
                }
                .font(.caption)
                .foregroundStyle(.white)
                .bold()
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15.0, style: .continuous))
            }
            Spacer()
        }
        .widgetBackground(backgroundView: Image("Beach").resizable().aspectRatio(contentMode: .fill))
        .widgetURL(URL(string: "widget://link1"))
    }
}

struct LockedInWidget: Widget {
    let kind: String = "LockedInWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockedInWidgetEntryView(entry: entry)
            } else {
                LockedInWidgetEntryView(entry: entry)
                    .background()
            }
        }
        .configurationDisplayName("Focus")
        .description("Focus for 25 minutes.")
    }
}

struct LockedInWidget2: Widget {
    let kind: String = "LockedInWidget2"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockedInWidgetEntry2View(entry: entry)
            } else {
                LockedInWidgetEntry2View(entry: entry)
                    .background()
            }
        }
        .configurationDisplayName("Breathe")
        .description("Take 5 breaths.")
    }
}
