//
//  SchedulePositionCalculator.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 27.06.2025.
//

import Foundation
import CoreGraphics
import CoreData

struct SchedulePositionCalculator {
    static func makePositionedEntries(
        date: Date,
        duties: [Duty],
        trainings: [Training],
        hourHeight: CGFloat = 60
    ) -> [PositionedEntry] {
        var result: [PositionedEntry] = []

        let calendar = Calendar.current
        let startOfDay = calendar.date(bySettingHour: 5, minute: 30, second: 0, of: date)!
        let secondsInHour: CGFloat = 3600

        for duty in duties {
            guard
                let start = duty.startTime,
                let end = duty.endTime,
                calendar.isDate(start, inSameDayAs: date)
            else { continue }

            let offset = CGFloat(start.timeIntervalSince(startOfDay)) / secondsInHour * hourHeight
            let duration = CGFloat(end.timeIntervalSince(start)) / secondsInHour * hourHeight

            result.append(PositionedEntry(
                id: duty.id ?? UUID(),
                type: .duty,
                title: "Дежурство",
                startTime: start,
                endTime: end,
                yOffset: offset,
                height: duration
            ))
        }

        for training in trainings {
            guard
                let start = training.date,
                let end = training.endTime,
                calendar.isDate(start, inSameDayAs: date)
            else { continue }

            let offset = CGFloat(start.timeIntervalSince(startOfDay)) / secondsInHour * hourHeight
            let duration = CGFloat(end.timeIntervalSince(start)) / secondsInHour * hourHeight

            result.append(PositionedEntry(
                id: training.id ?? UUID(),
                type: .training,
                title: training.type ?? "Тренировка",
                startTime: start,
                endTime: end,
                yOffset: offset,
                height: duration
            ))
        }

        return result
    }
}
