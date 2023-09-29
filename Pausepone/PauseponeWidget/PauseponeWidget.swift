//
//  PauseponeWidget.swift
//  PauseponeWidget
//
//  Created by Matsvei Liapich on 9/12/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
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

struct PauseponeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            ZStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Pause")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .bold()
                        Text("30 sec")
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
                        .opacity(0.1)
                    
                    Circle()
                        .trim(from: 0.0, to: min(0.8, 1.0))
                        .stroke(Color("Fawn"), style: StrokeStyle(lineWidth: 25.0, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: 270))
                }
                .offset(x: 70, y: 70)
            }
            .widgetURL(URL(string: "widget://link0"))
        }
        .widgetBackground(backgroundView: Color("WidgetBackground"))
    }
}



struct PauseponeWidget: Widget {
    let kind: String = "PauseponeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PauseponeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Start")
        .description("Start a 30 second Pause.")
    }
}

struct PauseponeWidget_Previews: PreviewProvider {
    static var previews: some View {
        PauseponeWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
