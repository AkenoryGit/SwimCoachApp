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

        // MARK: - Добавление дежурств
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
                height: duration,
                column: 0,
                totalColumns: 1,
                trainingType: nil,               // Для дежурств нет типа тренировки
                location: nil,                   // Для дежурств нет локации
                clientNames: [],                  // Для дежурств нет клиентов
                clientInfoText: ""
            ))
        }

        // MARK: - Группировка и позиционирование тренировок
        let dayTrainings = trainings
            .filter {
                if let start = $0.date {
                    return calendar.isDate(start, inSameDayAs: date)
                }
                return false
            }
            .sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }

        let overlapGroups = buildOverlapGroups(from: dayTrainings)
        for group in overlapGroups {
            buildColumns(for: group, startOfDay: startOfDay, hourHeight: hourHeight, into: &result)
        }

        return result
    }

    // MARK: - Группировка перекрывающихся тренировок
    private static func buildOverlapGroups(from trainings: [Training]) -> [[Training]] {
        var groups: [[Training]] = []

        for training in trainings {
            var matchedGroupIndices: [Int] = []

            for (index, group) in groups.enumerated() {
                if group.contains(where: { isOverlapping($0, training) }) {
                    matchedGroupIndices.append(index)
                }
            }

            if matchedGroupIndices.isEmpty {
                groups.append([training])
            } else {
                var mergedGroup = [training]
                for index in matchedGroupIndices.reversed() {
                    mergedGroup.append(contentsOf: groups.remove(at: index))
                }
                groups.append(mergedGroup)
            }
        }

        return groups
    }

    private static func isOverlapping(_ a: Training, _ b: Training) -> Bool {
        guard let aStart = a.date, let aEnd = a.endTime,
              let bStart = b.date, let bEnd = b.endTime else { return false }

        return max(aStart, bStart) < min(aEnd, bEnd)
    }

    // MARK: - Распределение по колонкам
    private static func buildColumns(
        for group: [Training],
        startOfDay: Date,
        hourHeight: CGFloat,
        into result: inout [PositionedEntry]
    ) {
        var columns: [[Training]] = []

        for training in group {
            var placed = false
            for columnIndex in 0..<columns.count {
                if let last = columns[columnIndex].last, !isOverlapping(last, training) {
                    columns[columnIndex].append(training)
                    placed = true
                    break
                }
            }
            if !placed {
                columns.append([training])
            }
        }

        for (colIndex, column) in columns.enumerated() {
            for training in column {
                guard let start = training.date, let end = training.endTime else { continue }

                // Строка ФИО + возраст
                let type = TrainingType(rawValue: training.type ?? "")
                let clientsSet = training.clients as? Set<Client> ?? []

                let clientInfoText: String
                let displayTitle: String

                if type == .group || type == .miniGroup || type == .split {
                    let baseTitle: String
                    switch type {
                    case .group:
                        baseTitle = "Группа"
                    case .miniGroup:
                        baseTitle = "Мини-группа"
                    case .split:
                        baseTitle = "Сплит"
                    default:
                        baseTitle = training.type ?? "Тренировка"
                    }
                    displayTitle = "\(baseTitle) (\(clientsSet.count) чел.)"
                    clientInfoText = ""
                } else {
                    displayTitle = clientsSet.compactMap { $0.fullName }.joined(separator: ", ")
                    clientInfoText = clientsSet
                        .map { client in
                            let name = client.fullName ?? "Без имени"
                            if let age = client.age(on: start) {
                                return "\(name), \(age) \(age.yearWord())"
                            } else {
                                return name
                            }
                        }
                        .joined(separator: "; ")
                }
                
                let offset = CGFloat(start.timeIntervalSince(startOfDay)) / 3600 * hourHeight
                let duration = CGFloat(end.timeIntervalSince(start)) / 3600 * hourHeight

                // Собираем имена клиентов
                var clientNames = ""
                if let clients = training.clients as? Set<Client> {
                    clientNames = clients
                        .compactMap { $0.fullName }
                        .joined(separator: ", ")
                }

                result.append(PositionedEntry(
                    id: training.id ?? UUID(),
                    type: .training,
                    title: displayTitle,
                    startTime: start,
                    endTime: end,
                    yOffset: offset,
                    height: duration,
                    column: colIndex,
                    totalColumns: columns.count,
                    trainingType: TrainingType(rawValue: training.type ?? ""),
                    location: TrainingLocation(rawValue: training.location ?? ""),
                    clientNames: (training.clients as? Set<Client>)?.compactMap { $0.fullName } ?? [],
                    clientInfoText: clientInfoText
                ))
            }
        }
    }
}
