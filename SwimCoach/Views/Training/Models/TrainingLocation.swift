//
//  TrainingLocation.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import Foundation

// MARK: - Перечисление возможных мест проведения тренировки

/// Возможные локации, где может проходить тренировка или занятие
enum TrainingLocation: String, CaseIterable, Identifiable {

    /// Большой бассейн (сокращённо "ББ")
    case bigPool = "ББ"

    /// Малый бассейн (сокращённо "ДБ")
    case smallPool = "ДБ"

    /// Тренажёрный зал (сокращённо "ТЗ")
    case gym = "ТЗ"

    // MARK: - Идентификатор для использования в SwiftUI (например, в Picker)

    /// Уникальный идентификатор — совпадает со значением rawValue
    var id: String { self.rawValue }
} 
