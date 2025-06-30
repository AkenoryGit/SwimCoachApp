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
    var onSelectEntry: ((PositionedEntry) -> Void)? = nil  // Добавлено

    @State private var selectedEntry: PositionedEntry?
    @State private var showDetailSheet = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(entries) { entry in
                    if entry.type == .training {
                        let spacing: CGFloat = 4
                        let totalColumns = max(entry.totalColumns, 1)
                        let columnWidth = (geometry.size.width - 70 - spacing * CGFloat(totalColumns - 1)) / CGFloat(totalColumns)
                        let xOffset = 70 + CGFloat(entry.column) * (columnWidth + spacing)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: columnWidth, height: entry.height)
                            .overlay(
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(.caption)
                                        .bold()
                                    Text(timeRangeText(entry: entry))
                                        .font(.caption2)
                                }
                                .padding(6)
                                .foregroundColor(.black),
                                alignment: .topLeading
                            )
                            .offset(x: xOffset, y: entry.yOffset)
                            .onTapGesture {
                                onSelectEntry?(entry) // Вызов обработчика выбора записи
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 20, height: entry.height)
                            .offset(x: 5, y: entry.yOffset)
                            .onTapGesture {
                                onSelectEntry?(entry) // Вызов обработчика выбора записи
                            }
                    }
                }
            }
        }
    }

    private func timeRangeText(entry: PositionedEntry) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: entry.startTime)) — \(formatter.string(from: entry.endTime))"
    }
}
