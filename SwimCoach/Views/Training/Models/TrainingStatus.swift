//
//  TrainingStatus.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

// Этот файл определяет перечисление TrainingStatus,
// которое описывает возможные статусы тренировки в приложении SwimCoach.

import SwiftUI

// Перечисление возможных статусов тренировки.
// Оно соответствует протоколам String (чтобы иметь строковое значение),
// CaseIterable (чтобы легко получить список всех вариантов, например, для отображения в Picker),
// и Identifiable (для использования в SwiftUI ForEach и списках).
enum TrainingStatus: String, CaseIterable, Identifiable {
    // Тренировка запланирована, но ещё не проведена
    case planned = "Запланирована"
    // Тренировка успешно проведена
    case completed = "Проведена"
    // Тренировка отменена (без списания)
    case cancelled = "Отменена"
    // Тренировка отменена, но со списанием оплаты
    case cancelledAndPaid = "Отменена со списанием"

    // Требуется для поддержки протокола Identifiable
    // Возвращает строковое значение как уникальный идентификатор
    var id: String { self.rawValue }

    // Цвет, связанный с каждым статусом, для визуального отображения
    var color: Color {
        switch self {
        case .planned: return .blue          // Синий — запланировано
        case .completed: return .green       // Зелёный — успешно проведено
        case .cancelled: return .red         // Красный — отменено
        case .cancelledAndPaid: return .orange // Оранжевый — отменено со списанием
        }
    }
}
