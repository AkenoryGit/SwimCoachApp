//
//  TrainingType.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import Foundation

// MARK: - Типы тренировок

/// Перечисление фиксированных типов тренировок, доступных в приложении
/// Используется при создании, отображении и фильтрации занятий
enum TrainingType: String, CaseIterable, Identifiable {

    /// Персональная тренировка
    case personal = "Персональная"

    /// Групповая тренировка
    case group = "Группа"

    /// Мини-группа (3–5 человек)
    case miniGroup = "Мини-группа"

    /// Сплит — занятие с двумя клиентами
    case split = "Сплит"

    /// Грудничковое плавание (для младенцев)
    case infant = "Грудничковое плавание"

    /// Детский бассейн (для детей 3–6 лет)
    case babyPool = "Детский бассейн"

    /// СПТ — стартовая персональная тренировка
    case startingTraining = "СПТ"

    // MARK: - Идентификатор для SwiftUI

    /// Уникальный идентификатор, используется в SwiftUI `Picker`, `ForEach` и т.п.
    var id: String { self.rawValue }
    
    /// Человекочитаемое имя типа тренировки
    var displayName: String {
        return self.rawValue
    }
}
