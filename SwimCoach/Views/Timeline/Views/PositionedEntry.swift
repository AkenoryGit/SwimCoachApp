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
}
