//
//  TrainingLocation.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import Foundation

enum TrainingLocation: String, CaseIterable, Identifiable {
    case bigPool = "ББ"
    case smallPool = "ДБ"
    case gym = "ТЗ"

    var id: String { self.rawValue }
}
