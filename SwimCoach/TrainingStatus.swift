//
//  TrainingStatus.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

enum TrainingStatus: String, CaseIterable, Identifiable {
    case planned = "Запланирована"
    case completed = "Проведена"
    case cancelled = "Отменена"
    case cancelledAndPaid = "Отменена со списанием"

    var id: String { self.rawValue }

    var color: Color {
        switch self {
        case .planned: return .blue
        case .completed: return .green
        case .cancelled: return .red
        case .cancelledAndPaid: return .orange
        }
    }
}
