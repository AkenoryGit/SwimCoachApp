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
    return duties.compactMap { duty in
        guard let start = duty.startTime, let end = duty.endTime else { return nil }

        let calendar = Calendar.current
        let minHour: CGFloat = 6

        let startMinutes = CGFloat(calendar.component(.hour, from: start) * 60 + calendar.component(.minute, from: start))
        let endMinutes = CGFloat(calendar.component(.hour, from: end) * 60 + calendar.component(.minute, from: end))

        let clampedStart = max(startMinutes, 6 * 60)
        let clampedEnd = min(endMinutes, 23 * 60)

        let duration = clampedEnd - clampedStart
        guard duration > 0 else { return nil }

        let topOffset = clampedStart - minHour * 60
        return PositionedDuty(duty: duty, topOffset: topOffset, height: duration)
    }
}
