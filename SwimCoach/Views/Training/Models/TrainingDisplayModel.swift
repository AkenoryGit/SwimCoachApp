//
//  TrainingDisplayModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 21.05.2025.
//

import Foundation

// MARK: - Модель отображения тренировки для UI (display model)

/// Структура, представляющая тренировку в виде, удобном для отображения в SwiftUI
struct TrainingDisplayModel: Identifiable {
    /// Уникальный идентификатор тренировки
    let id: UUID
    
    /// Связанный объект Training из Core Data
    let training: Training

    /// Тип тренировки (например: "Тренировка", "Дежурство" и т.д.)
    let type: String

    /// Список клиентов, участвующих в тренировке (имена)
    let clients: [String]

    /// Время начала тренировки
    let startTime: Date

    /// Время окончания тренировки
    let endTime: Date
}

// MARK: - Расширение для преобразования Training (Core Data) в TrainingDisplayModel

extension Training {

    /// Преобразует объект Training из Core Data в облегчённую модель TrainingDisplayModel для UI
    func toDisplayModel() -> TrainingDisplayModel? {
        // Проверяем обязательные поля: id, дата начала и окончания
        guard let id = self.id,
              let start = self.date,
              let end = self.endTime else {
            return nil
        }

        // Преобразуем список клиентов в массив имён
        let clients = (self.clients as? Set<Client>)?.compactMap { $0.fullName } ?? []

        // Возвращаем адаптированную модель
        return TrainingDisplayModel(
            id: id,
            training: self,
            type: self.type ?? "Без типа",
            clients: clients,
            startTime: start,
            endTime: end
        )
    }
}
