//
//  AllTrainingsViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - ViewModel для отображения всех тренировок

final class AllTrainingsViewModel: ObservableObject {

    // MARK: - Опубликованные свойства

    /// Массив отображаемых тренировок (адаптированная модель для UI)
    @Published var trainings: [TrainingDisplayModel] = []

    // MARK: - Загрузка тренировок из Core Data

    /// Получает все тренировки из Core Data и обновляет их статусы при необходимости
    func fetchTrainings(context: NSManagedObjectContext) {
        // Создаём запрос на все объекты Training
        let request: NSFetchRequest<Training> = Training.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Training.date, ascending: false)]

        do {
            // Загружаем результаты из Core Data
            let results = try context.fetch(request)

            var models: [TrainingDisplayModel] = []

            for training in results {
                // MARK: - Автообновление статуса прошедших тренировок
                if training.status == "Запланирована",
                   let endTime = training.endTime,
                   endTime < Date() {

                    // Обновляем статус на "Проведена"
                    training.status = "Проведена"

                    // Списываем занятие у клиента, если это возможно
                    if let clients = training.clients as? Set<Client> {
                        for client in clients {
                            if let balances = client.balances as? Set<TrainingBalance>,
                               let balance = balances.first(where: {
                                   $0.type == training.type && $0.count > 0
                               }) {
                                balance.count -= 1
                            }
                        }
                    }
                }

                // Преобразуем в отображаемую модель и добавляем в список
                if let model = training.toDisplayModel() {
                    models.append(model)
                }
            }

            // Сохраняем все изменения в базу
            try context.save()

            // Обновляем данные в интерфейсе
            trainings = models

        } catch {
            // Обработка ошибки
            print("❌ Ошибка при загрузке или обновлении тренировок: \(error.localizedDescription)")
            trainings = []
        }
    }
} 
