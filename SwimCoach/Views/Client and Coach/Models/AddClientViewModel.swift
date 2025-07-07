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

    func saveClient(to context: NSManagedObjectContext, allowDuplicate: Bool = false) -> Bool {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Проверка на дубликат
        if !allowDuplicate {
            let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "fullName ==[cd] %@", trimmedName)

            do {
                let existingClients = try context.fetch(fetchRequest)
                if !existingClients.isEmpty {
                    return false // Найден дубликат
                }
            } catch {
                print("❌ Ошибка проверки дубликатов: \(error.localizedDescription)")
                return false
            }
        }

        // Сохраняем клиента
        let newClient = Client(context: context)
        newClient.id = UUID()
        newClient.fullName = trimmedName
        newClient.phone = phone
        newClient.birthDate = isBirthDateSpecified ? birthDate : nil
        newClient.notes = notes

        for (type, count) in trainingCounts where count > 0 {
            let balance = TrainingBalance(context: context)
            balance.id = UUID()
            balance.type = type.rawValue
            balance.count = Int32(count)
            balance.client = newClient
        }

        do {
            try context.save()
            return true
        } catch {
            print("❌ Ошибка при сохранении клиента: \(error.localizedDescription)")
            return false
        }
    }
}
