//
//  TrainingDutyTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 27.06.2025.
//

import SwiftUI

/// Слой временной шкалы, отображающий блоки тренировок и дежурств
struct TrainingDutyTimelineLayer: View {
    let entries: [PositionedEntry]
    let onUpdate: () -> Void

    @State private var selectedEntry: PositionedEntry?
    @State private var showDetailSheet = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(entries) { entry in
                RoundedRectangle(cornerRadius: 8)
                    .fill(entry.type == .training ? Color.blue.opacity(0.3) : Color.red.opacity(0.3))
                    .frame(
                        width: entry.type == .training ? UIScreen.main.bounds.width - 80 : 20,
                        height: entry.height
                    )
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            if entry.type == .training {
                                Text(entry.title)
                                    .font(.caption)
                                    .bold()
                                Text(timeRangeText(entry: entry))
                                    .font(.caption2)
                            }
                        }
                        .padding(6)
                        .foregroundColor(.black),
                        alignment: .topLeading
                    )
                    .offset(
                        x: entry.type == .training ? 70 : 5,
                        y: entry.yOffset
                    )
                    .onTapGesture {
                        selectedEntry = entry
                        showDetailSheet = true
                    }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry, onUpdate: onUpdate)
        }
    }

    private func timeRangeText(entry: PositionedEntry) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: entry.startTime)) — \(formatter.string(from: entry.endTime))"
    }
}
