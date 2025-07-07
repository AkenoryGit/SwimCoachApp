//
//  RepeatFrequency.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import Foundation

enum RepeatFrequency: String, Identifiable {
    case daily = "Каждый день"
    case everyOtherDay = "Через день"
    case weekly = "Каждую неделю"
    case monthly = "Каждый месяц"
    case noneSelected = "Не повторять"

    static var allCases: [RepeatFrequency] {
        [.daily, .everyOtherDay, .weekly, .monthly]
    }

    static var allCasesWithNone: [RepeatFrequency] {
        [.noneSelected] + allCases
    }

    var id: String { rawValue }

    var title: String {
        rawValue
    }

    var daysInterval: Int {
        switch self {
        case .daily: return 1
        case .everyOtherDay: return 2
        case .weekly: return 7
        case .monthly: return 30
        case .noneSelected: return 0
        }
    }

    static func from(raw: String?) -> RepeatFrequency? {
        guard let raw = raw else { return nil }
        return allCasesWithNone.first(where: { $0.rawValue == raw })
    }

    func nextDate(from baseStart: Date, endDate baseEnd: Date, step: Int) -> (Date, Date)? {
        let calendar = Calendar.current

        switch self {
        case .daily:
            if let newStart = calendar.date(byAdding: .day, value: step, to: baseStart),
               let newEnd = calendar.date(byAdding: .day, value: step, to: baseEnd) {
                return (newStart, newEnd)
            }
        case .everyOtherDay:
            if let newStart = calendar.date(byAdding: .day, value: step * 2, to: baseStart),
               let newEnd = calendar.date(byAdding: .day, value: step * 2, to: baseEnd) {
                return (newStart, newEnd)
            }
        case .weekly:
            if let newStart = calendar.date(byAdding: .weekOfYear, value: step, to: baseStart),
               let newEnd = calendar.date(byAdding: .weekOfYear, value: step, to: baseEnd) {
                return (newStart, newEnd)
            }
        case .monthly:
            if let newStart = calendar.date(byAdding: .month, value: step, to: baseStart),
               let newEnd = calendar.date(byAdding: .month, value: step, to: baseEnd) {
                return (newStart, newEnd)
            }
        case .noneSelected:
            return nil
        }

        return nil
    }
}
