//
//  AnyIdentifiableEntry.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 25.06.2025.
//

import Foundation

// MARK: - Объединяет тренировку и дежурство для универсального отображения в списке
enum AnyIdentifiableEntry: Identifiable {
    case training(Training)
    case duty(Duty)

    // MARK: - Уникальный идентификатор
    var id: UUID {
        switch self {
        case .training(let t): return t.id ?? UUID()
        case .duty(let d): return d.id ?? UUID()
        }
    }

    // MARK: - Дата записи (для сортировки и отображения)
    var date: Date? {
        switch self {
        case .training(let t): return t.date
        case .duty(let d): return d.startTime // Используем startTime, потому что поля `date` нет
        }
    }

    // MARK: - Заголовок записи (тип тренировки или слово "Дежурство")
    var title: String {
        switch self {
        case .training(let t): return t.type ?? "Без типа"
        case .duty: return "Дежурство"
        }
    }

    // MARK: - Список клиентов
    var clientNames: String {
        switch self {
        case .training(let t):
            if let clients = t.clients as? Set<Client>, !clients.isEmpty {
                return clients.compactMap { $0.fullName }.joined(separator: ", ")
            } else {
                return ""
            }
        case .duty:
            return "" // У дежурств нет клиентов
        }
    }
}

extension AnyIdentifiableEntry {
    var type: EntryType {
        switch self {
        case .training: return .training
        case .duty: return .duty
        }
    }

    var startTime: Date {
        switch self {
        case .training(let t): return t.date ?? Date()
        case .duty(let d): return d.startTime ?? Date()
        }
    }

    var endTime: Date {
        switch self {
        case .training(let t): return t.endTime ?? Date()
        case .duty(let d): return d.endTime ?? Date()
        }
    }

    func toPositionedEntry() -> PositionedEntry {
        PositionedEntry(
            id: self.id,
            type: self.type,
            title: self.title,
            startTime: self.startTime,
            endTime: self.endTime,
            yOffset: 0,
            height: 0,
            column: 0,
            totalColumns: 1,
            trainingType: nil,               // Для дежурств нет типа тренировки
            location: nil,                   // Для дежурств нет локации
            clientNames: []                  // Для дежурств нет клиентов
        )
    }
}
