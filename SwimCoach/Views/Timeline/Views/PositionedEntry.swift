//
//  PositionedEntry.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 27.06.2025.
//

import Foundation
import CoreGraphics

enum PositionedEntryType {
    case duty
    case training
}

struct PositionedEntry: Identifiable {
    let id: UUID
    let type: EntryType
    let title: String
    let startTime: Date
    let endTime: Date
    let yOffset: CGFloat
    let height: CGFloat
    let column: Int
    let totalColumns: Int
    
    let trainingType: TrainingType?   // nil для дежурств
    let location: TrainingLocation?   // nil для дежурств
    let clientNames: [String]         // список ФИО клиентов, пустой для дежурств
    let clientInfoText: String
    
    let trainingObject: Training?  // nil для дежурств
    let dutyObject: Duty?          // nil для тренировок
}

extension PositionedEntry {
    static func from(training: Training) -> PositionedEntry {
        let id = training.id ?? UUID()
        let title = training.type ?? "Тренировка"
        let start = training.date ?? Date()
        let end = training.endTime ?? Date().addingTimeInterval(60 * 50)
        let clients = training.clients as? Set<Client> ?? []
        let clientNames = clients.compactMap { $0.fullName }
        let clientInfo = clientNames.joined(separator: ", ")

        return PositionedEntry(
            id: id,
            type: .training,
            title: title,
            startTime: start,
            endTime: end,
            yOffset: 0,
            height: 0,
            column: 0,
            totalColumns: 1,
            trainingType: TrainingType(rawValue: training.type ?? ""),
            location: TrainingLocation(rawValue: training.location ?? ""),
            clientNames: clientNames,
            clientInfoText: clientInfo,
            trainingObject: training,
            dutyObject: nil
        )
    }

    static func from(duty: Duty) -> PositionedEntry {
        let id = duty.id ?? UUID()
        let title = duty.trainerName ?? "Дежурство"
        let start = duty.startTime ?? Date()
        let end = duty.endTime ?? Date().addingTimeInterval(60 * 50)

        return PositionedEntry(
            id: id,
            type: .duty,
            title: title,
            startTime: start,
            endTime: end,
            yOffset: 0,
            height: 0,
            column: 0,
            totalColumns: 1,
            trainingType: nil,
            location: nil,
            clientNames: [],
            clientInfoText: "",
            trainingObject: nil,
            dutyObject: duty
        )
    }
}
