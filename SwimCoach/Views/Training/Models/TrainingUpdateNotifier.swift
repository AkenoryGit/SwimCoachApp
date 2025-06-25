//
//  TrainingUpdateNotifier.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import Foundation
import CoreData

// MARK: - Оповещатель об обновлении тренировок (Singleton)

/// Класс, используемый для централизованного оповещения SwiftUI-интерфейса о том, что данные тренировок обновились
final class TrainingUpdateNotifier: ObservableObject {

    // MARK: - Singleton

    /// Общий экземпляр (singleton) — используется во всём приложении
    static let shared = TrainingUpdateNotifier()

    // MARK: - Переменная для отслеживания изменений

    /// Когда переменная меняется, SwiftUI перерисовывает подписанные представления
    @Published var didChange = false

    // MARK: - Приватный инициализатор (запрещает создание других экземпляров)

    private init() {}

    // MARK: - Метод ручного уведомления об изменении данных

    /// Меняет состояние переменной `didChange`, что вызывает обновление UI
    func notifyUpdate() {
        didChange.toggle()
    }

    // MARK: - Автообновление статуса прошедших тренировок в Core Data

    /// Обновляет статусы всех прошедших тренировок на "Проведена"
    func updateStatusesIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Training> = Training.fetchRequest()

        // Фильтруем только "Запланированные" тренировки
        request.predicate = NSPredicate(format: "status == %@", "Запланирована")

        do {
            let scheduledTrainings = try context.fetch(request)
            let now = Date()

            for training in scheduledTrainings {
                if let endTime = training.endTime,
                   let date = training.date,
                   endTime < now,
                   Calendar.current.isDate(date, inSameDayAs: now) || date < now {

                    training.status = "Проведена"
                }
            }

            // Сохраняем изменения, если они есть
            if context.hasChanges {
                try context.save()
                self.didChange.toggle()
            }

        } catch {
            print("Ошибка при обновлении статусов: \(error.localizedDescription)")
        }
    }
}

