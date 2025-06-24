//
//  TimelineCalculation.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - Структура для позиционированных тренировок
struct PositionedTraining: Identifiable {
    var id: NSManagedObjectID { training.objectID }
    let training: Training
    let topOffset: CGFloat
    let height: CGFloat
    let column: Int
    let totalColumns: Int
}

// MARK: - Расчёт позиции и высоты тренировок
func calculatePositionedTrainings(from trainings: [Training], hourHeight: CGFloat) -> [PositionedTraining] {
    let sorted = trainings.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
    var result: [PositionedTraining] = []
    var currentGroup: [Training] = []

    func addGroup(_ group: [Training]) {
        let count = group.count
        for (index, training) in group.enumerated() {
            if let (topOffset, height) = makeTrainingOffsetHeight(from: training, hourHeight: hourHeight) {
                result.append(PositionedTraining(
                    training: training,
                    topOffset: topOffset,
                    height: height,
                    column: index,
                    totalColumns: count
                ))
            }
        }
    }

    for training in sorted {
        guard let start = training.date, let end = training.endTime else { continue }
        if currentGroup.isEmpty {
            currentGroup.append(training)
        } else {
            let overlaps = currentGroup.contains { other in
                guard let otherStart = other.date, let otherEnd = other.endTime else { return false }
                return max(start, otherStart) < min(end, otherEnd)
            }
            if overlaps {
                currentGroup.append(training)
            } else {
                addGroup(currentGroup)
                currentGroup = [training]
            }
        }
    }

    if !currentGroup.isEmpty {
        addGroup(currentGroup)
    }

    return result
}

// MARK: - Расчёт позиции и высоты дежурств
func makePositionedDuties(from duties: [Duty], on day: Date, hourHeight: CGFloat) -> [PositionedDuty] {
    let calendar = Calendar.current
    let sixAMUTC = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: day)!

    return duties.compactMap { duty in
        guard let start = duty.startTime, let end = duty.endTime else { return nil }

        let startMinutes = CGFloat(start.timeIntervalSince(sixAMUTC)) / 60.0
        let endMinutes = CGFloat(end.timeIntervalSince(sixAMUTC)) / 60.0
        let duration = endMinutes - startMinutes
        guard duration > 0 else { return nil }

        let minuteHeight = hourHeight / 60.0
        let topOffset = startMinutes * minuteHeight / 2
        let height = duration * minuteHeight

        return PositionedDuty(duty: duty, topOffset: topOffset, height: height)
    }
}

// MARK: - Вспомогательная функция для получения позиции и высоты одной тренировки
func makeTrainingOffsetHeight(from training: Training, hourHeight: CGFloat) -> (topOffset: CGFloat, height: CGFloat)? {
    guard let start = training.date, let end = training.endTime else { return nil }
    let calendar = Calendar.current
    let minHour: CGFloat = 6

    let startOfDay = calendar.startOfDay(for: start)
    let startMinutes = CGFloat(calendar.dateComponents([.minute], from: startOfDay, to: start).minute ?? 0 + (calendar.dateComponents([.hour], from: startOfDay, to: start).hour ?? 0) * 60)
    let endMinutes = CGFloat(calendar.dateComponents([.minute], from: startOfDay, to: end).minute ?? 0 + (calendar.dateComponents([.hour], from: startOfDay, to: end).hour ?? 0) * 60)

    let clampedStart = max(startMinutes, minHour * 60)
    let clampedEnd = min(endMinutes, 23 * 60)

    let duration = clampedEnd - clampedStart
    guard duration > 0 else { return nil }

    let minuteHeight = hourHeight / 60.0
    let topOffset = (clampedStart - minHour * 60) * minuteHeight
    let height = duration * minuteHeight

    return (topOffset, height)
}

// MARK: - Индикатор текущего времени
func currentTimeOffset() -> CGFloat? {
    let calendar = Calendar.current
    let now = Date()
    let hourHeight: CGFloat = 60
    let minHour: CGFloat = 6

    let components = calendar.dateComponents([.hour, .minute], from: now)
    guard let hour = components.hour, let minute = components.minute else { return nil }

    let totalMinutes = CGFloat(hour * 60 + minute)
    let clampedMinutes = max(min(totalMinutes, 23 * 60), minHour * 60)

    return clampedMinutes - minHour * 60
}
