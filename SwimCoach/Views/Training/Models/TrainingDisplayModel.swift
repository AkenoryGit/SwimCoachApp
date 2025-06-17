//
//  TrainingDisplayModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 21.05.2025.
//

// Этот файл описывает простую структуру данных TrainingDisplayModel,
// которая используется для отображения информации о тренировке в пользовательском интерфейсе.
// Это облегчённая модель (display model), созданная на основе более сложной модели Core Data (Training),
// и она используется, например, чтобы отобразить тренировку в списке или на экране, не связываясь напрямую с базой данных.

import Foundation

// Структура TrainingDisplayModel используется в SwiftUI в списках или ForEach,
// поэтому она должна быть уникально идентифицируема — для этого она подчиняется протоколу Identifiable.
struct TrainingDisplayModel: Identifiable {
    // Уникальный идентификатор тренировки
    let id: UUID
    
    // Тип тренировки (например: "Тренировка", "Дежурство" и т.д.)
    let type: String
    
    // Список клиентов, которые участвуют в тренировке (просто список имён)
    let clients: [String]
    
    // Время начала тренировки
    let startTime: Date
    
    // Время окончания тренировки
    let endTime: Date
}

// Расширение для объекта Training из Core Data.
// Добавляет функцию, которая превращает Training в более простой и удобный для отображения объект TrainingDisplayModel.
extension Training {

    // Преобразование Training в TrainingDisplayModel
    func toDisplayModel() -> TrainingDisplayModel? {
        // Безопасно извлекаем необходимые значения: id, дату начала и дату окончания
        guard let id = self.id, // id должен быть не nil
              let start = self.date, // date должен быть не nil
              let end = self.endTime else { return nil } // endTime должен быть не nil

        // Преобразуем множество клиентов (Set<Client>), связанных с тренировкой, в массив строк с именами
        let clients = (self.clients as? Set<Client>)?.compactMap { $0.fullName } ?? []

        // Возвращаем объект TrainingDisplayModel — это облегчённая структура данных для отображения на экране
        return TrainingDisplayModel(
            id: id, // Уникальный идентификатор тренировки
            type: self.type ?? "Без типа", // Если тип не задан, подставляется "Без типа"
            clients: clients,              // Список клиентов
            startTime: start,              // Время начала тренировки
            endTime: end                   // Время окончания тренировки
        )
    }
}
