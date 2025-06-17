//
//  TrainingType.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import Foundation

/// Перечисление всех возможных типов тренировок.
/// Это фиксированный список, который используется:
/// - при добавлении тренировок
/// - при оплате тренировок
/// - при списании тренировок
enum TrainingType: String, CaseIterable, Identifiable {
    case personal = "Персональная"
    case group = "Группа"
    case miniGroup = "Мини-группа"
    case split = "Сплит"
    case infant = "Грудничковое плавание"
    case babyPool = "Детский бассейн"
    case startingTraining = "СПТ"

    /// Уникальный идентификатор для каждого значения enum (используется в ForEach и Picker)
    var id: String { self.rawValue }

    /// Можно добавить сокращённый код для внутреннего хранения, если нужно (необязательно)
    var shortCode: String {
        switch self {
        case .personal: return "PT"
        case .group: return "GR"
        case .miniGroup: return "MG"
        case .split: return "SP"
        case .infant: return "GP"
        case .babyPool: return "DB"
        case .startingTraining: return "SPT"
        }
    }
}
