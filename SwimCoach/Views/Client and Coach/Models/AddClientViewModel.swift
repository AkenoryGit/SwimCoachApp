//
//  AddClientViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import SwiftUI
import CoreData

// Класс модели представления (ViewModel), который управляет состоянием формы добавления клиента
class AddClientViewModel: ObservableObject { // ObservableObject позволяет отслеживать изменения и обновлять представление
    @Published var fullName = "" // @Published позволяет SwiftUI автоматически обновлять представление при изменении этих свойств
    @Published var isBirthDateSpecified: Bool = true
    @Published var phone = "" // Телефон клиента
    @Published var birthDate = Date() // Дата рождения клиента, по умолчанию — текущая дата
    @Published var notes = "" // Примечания к клиенту, например ограничения по здоровью
    @Published var trainingCounts: [TrainingType: Int] = { // Словарь для хранения количества оплаченных тренировок по типам
        var result: [TrainingType: Int] = [:] // Инициализация словаря с типами тренировок
        for type in TrainingType.allCases { // Перебираем все возможные типы тренировок
            result[type] = 0 // Устанавливаем начальное значение 0 для каждого типа
        }
        return result // Возвращаем заполненный словарь
    }()

    var isFormValid: Bool { // Проверка валидности формы: ФИО не должно быть пустым
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty // Проверяем, что ФИО не пустое после удаления пробелов
    }

    func saveClient(to context: NSManagedObjectContext) { // Функция для сохранения клиента в Core Data
        let newClient = Client(context: context) // Создаем новый объект Client в контексте Core Data
        newClient.id = UUID() // Генерируем уникальный идентификатор для клиента
        newClient.fullName = fullName // Устанавливаем полное имя клиента
        newClient.phone = phone // Устанавливаем телефон клиента
        newClient.birthDate = isBirthDateSpecified ? birthDate : nil
        newClient.notes = notes // Устанавливаем примечания к клиенту

        for (type, count) in trainingCounts where count > 0 { // Перебираем словарь trainingCounts
            let balance = TrainingBalance(context: context) // Создаем новый объект TrainingBalance в контексте Core Data
            balance.id = UUID() // Генерируем уникальный идентификатор для баланса
            balance.type = type.rawValue // Устанавливаем тип тренировки из перечисления TrainingType
            balance.count = Int32(count) // Устанавливаем количество оплаченных тренировок, преобразуя Int в Int32
            balance.client = newClient // Связываем баланс с клиентом
        }

        do { // Попытка сохранить контекст Core Data
            try context.save() // Сохраняем изменения в контексте
        } catch { // Обработка ошибки сохранения
            print("Ошибка при сохранении клиента: \(error.localizedDescription)") // Выводим сообщение об ошибке в консоль
        }
    }
}
