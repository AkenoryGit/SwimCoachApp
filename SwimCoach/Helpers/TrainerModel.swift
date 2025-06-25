//
//  TrainerModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation

// MARK: - Модель тренера

/// Структура `Trainer` описывает сущность тренера.
/// Используется, например, при назначении дежурств.
///
/// `Identifiable` — позволяет использовать в SwiftUI в списках.
/// `Hashable` — нужен, чтобы сравнивать и хранить тренеров в множествах, словарях и т.п.
struct Trainer: Identifiable, Hashable {
    let id: UUID              // Уникальный идентификатор тренера
    let fullName: String      // Полное имя тренера
}

// MARK: - Пример списка тренеров (заглушка / мок-данные)

/// Список тренеров, используемый для выбора в интерфейсе (Picker и т.п.).
/// Можно заменить на реальные данные из Core Data или API, если потребуется.
let mockTrainers: [Trainer] = [
    Trainer(id: UUID(), fullName: "Дмитрий Дудник"),
    Trainer(id: UUID(), fullName: "Иванов Иван"),
    Trainer(id: UUID(), fullName: "Петров Пётр")
]
