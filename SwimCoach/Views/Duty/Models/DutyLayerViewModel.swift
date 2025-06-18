//
//  DutyLayerViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 18.06.2025.
//

import Foundation
import CoreData

// Эта модель управляет загрузкой и хранением дежурств для выбранной даты
class DutyLayerViewModel: ObservableObject {
    @Published var duties: [Duty] = [] // Массив для хранения дежурств
    
    private let context: NSManagedObjectContext // Контекст Core Data для выполнения запросов

    init(context: NSManagedObjectContext) { // Инициализация с контекстом Core Data
        self.context = context // Сохраняем контекст
    }

    func fetch(for selectedDate: Date) { // Метод для загрузки дежурств для выбранной даты
        let calendar = Calendar.current // Получаем текущий календарь
        let startOfDay = calendar.startOfDay(for: selectedDate) // Получаем начало дня для выбранной даты
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return } // Получаем конец дня (следующий день)

        let request = NSFetchRequest<Duty>(entityName: "Duty") // Создаем запрос для сущности Duty
        request.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", startOfDay as NSDate, endOfDay as NSDate) // Устанавливаем предикат для фильтрации по времени начала дежурства
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Duty.startTime, ascending: true)] // Сортируем по времени начала дежурства

        do { // Выполняем запрос и сохраняем результаты
            self.duties = try context.fetch(request) // Пытаемся выполнить запрос и сохранить результаты в массив duties
        } catch {
            // Если при выполнении запроса к Core Data возникла ошибка (например, проблема с сохранением, загрузкой или с предикатом),
            // выполнение попадёт в этот блок `catch`.

            print("❌ Ошибка при загрузке дежурств: \(error)")
            // Мы выводим в консоль сообщение об ошибке, используя встроенную переменную `error`,
            // которая содержит объект с описанием возникшей ошибки. Это полезно для отладки.

            self.duties = []
            // Чтобы приложение не зависло и не отображало старые данные,
            // мы явно очищаем массив `duties`, показывая, что дежурства не были загружены.
        }
    }
}
