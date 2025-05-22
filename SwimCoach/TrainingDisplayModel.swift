//
//  TrainingDisplayModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 21.05.2025.
//

import Foundation

struct TrainingDisplayModel: Identifiable {
    let id: UUID
    let type: String
    let clients: [String]
    let startTime: Date
    let endTime: Date
}


