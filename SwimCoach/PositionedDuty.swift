//
//  PositionedDuty.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

import SwiftUI
import CoreData

struct PositionedDuty: Identifiable {
    var id: NSManagedObjectID { duty.objectID }
    let duty: Duty
    let topOffset: CGFloat
    let height: CGFloat
}

func calculatePositionedDuties(from duties: [Duty], hourHeight: CGFloat) -> [PositionedDuty] {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    print("🟡 calculatePositionedDuties вызвана, всего \(duties.count) дежурств")
    let minHour: CGFloat = 6

    return duties.compactMap { duty in
        guard let start = duty.startTime, let end = duty.endTime else { return nil }

        // Get the start of the day for the duty's date
        let startOfDay = calendar.startOfDay(for: start)

        // Calculate minutes since start of day
        let componentsStart = calendar.dateComponents([.hour, .minute], from: startOfDay, to: start)
        let componentsEnd = calendar.dateComponents([.hour, .minute], from: startOfDay, to: end)

        let startMinutes = CGFloat((componentsStart.hour ?? 0) * 60 + (componentsStart.minute ?? 0))
        let endMinutes = CGFloat((componentsEnd.hour ?? 0) * 60 + (componentsEnd.minute ?? 0))

        // Clamp to timeline range (6:00 to 23:00)
        let clampedStart = max(startMinutes, minHour * 60)
        let clampedEnd = min(endMinutes, 23 * 60)

        let duration = clampedEnd - clampedStart
        guard duration > 0 else { return nil }

        let minuteHeight = hourHeight / 60.0
        let topOffset = (clampedStart - minHour * 60) * minuteHeight
        let height = duration * minuteHeight
        
        print("🟡 \(duty.startTime?.formatted() ?? "—") – offset: \(topOffset), height: \(height)")

        return PositionedDuty(duty: duty, topOffset: topOffset, height: height)
    }
}
