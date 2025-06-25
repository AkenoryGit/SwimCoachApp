//
//  TrainingStatus.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

// MARK: - Статусы тренировки

/// Возможные состояния тренировки в приложении SwimCoach
/// Используется для управления отображением и логикой в SwiftUI
enum TrainingStatus: String, CaseIterable, Identifiable {

    /// Тренировка запланирована, но ещё не проведена
    case planned = "Запланирована"

    /// Тренировка успешно проведена
    case completed = "Проведена"

    /// Тренировка отменена без списания
    case cancelled = "Отменена"

    /// Тренировка отменена, но со списанием оплаты
    case cancelledAndPaid = "Отменена со списанием"

    // MARK: - Идентификатор для SwiftUI

    /// Уникальный идентификатор для использования в SwiftUI Picker или ForEach
    var id: String { self.rawValue }

    // MARK: - Цвет визуального статуса

    /// Цвет, связанный с каждым статусом, для UI отображения
    var color: Color {
        switch self {
        case .planned:
            return .blue         // Синий — запланировано
        case .completed:
            return .green        // Зелёный — успешно проведено
        case .cancelled:
            return .red          // Красный — отменено
        case .cancelledAndPaid:
            return .orange       // Оранжевый — отменено со списанием
        }
    }
}

