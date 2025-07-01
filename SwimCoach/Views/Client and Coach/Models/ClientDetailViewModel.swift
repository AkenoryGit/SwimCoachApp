//
//  ClientDetailViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import SwiftUI
import CoreData

// Этот класс представляет собой ViewModel для детального просмотра клиента в приложении SwimCoach.
class ClientDetailViewModel: ObservableObject {
    @Published var client: Client // Модель клиента, которую мы будем отображать и редактировать
    @Published var showingDeleteAlert = false // Флаг для показа предупреждения при удалении клиента
    @Published var showingEditForm = false // Флаг для показа формы редактирования клиента
    @Published var alertMessage: String = ""
    @Published var showingAlert: Bool = false
//    @Published var isBirthDateSpecified: Bool = true

    init(client: Client) { // инициализатор принимает объект клиента
        self.client = client // сохраняем его в свойство
//        self.isBirthDateSpecified = client.birthDate != nil
    }

    var fullName: String { // Возвращает полное имя клиента, если оно задано, иначе возвращает "Без имени"
        client.fullName ?? "Без имени" // Если полное имя не задано, возвращаем "Без имени"
    }

    var birthDateFormatted: String? { // Форматированная дата рождения клиента
        guard let birthDate = client.birthDate else { return nil } // Проверяем, что дата рождения задана
        let formatter = DateFormatter() // Создаем форматтер для даты
        formatter.locale = Locale(identifier: "ru_RU") // Устанавливаем локаль на русский
        formatter.dateStyle = .long // Устанавливаем стиль даты на длинный формат
        return formatter.string(from: birthDate) // Возвращаем отформатированную дату
    }

    var phone: String? { // Возвращает номер телефона клиента, если он задан
        client.phone // Если номер телефона не задан, возвращаем nil
    }

    var notes: String? { // Возвращает заметки клиента, если они заданы
        client.notes // Если заметки не заданы, возвращаем nil
    }

    var balances: [String] { // Возвращает список балансов клиента по типам тренировок
        guard let balances = client.balances as? Set<TrainingBalance> else { return [] } // Проверяем, что балансы заданы как множество TrainingBalance
        return TrainingType.allCases.compactMap { type in // Для каждого типа тренировки
            if let balance = balances.first(where: { $0.type == type.rawValue }), balance.count > 0 { // Проверяем, есть ли баланс для этого типа и его количество больше 0
                return "\(type.rawValue): \(balance.count)" // Если да, возвращаем строку с типом и количеством
            }
            return nil // Если баланса нет или количество 0, возвращаем nil
        }
    }

    var relatedClients: [String] { // Возвращает список связанных клиентов
        guard let related = client.relatedClients as? Set<Client> else { return [] } // Проверяем, что связанные клиенты заданы как множество Client
        return related.compactMap { $0.fullName } // Возвращаем массив полных имен связанных клиентов
    }

    func deleteClient(context: NSManagedObjectContext, dismiss: @escaping () -> Void) {
        // Проверка: есть ли тренировки у клиента
        if let trainings = client.training as? Set<Training>, !trainings.isEmpty {
            // Показываем alert через published свойство
            alertMessage = "Нельзя удалить клиента, у которого есть тренировки."
            showingAlert = true
            return
        }

        client.isDeletedClient = true
        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка при удалении клиента: \(error.localizedDescription)")
        }
    }
    
    func reload() {
        // Просто сообщаем SwiftUI, что данные клиента могли измениться
        objectWillChange.send()
    }
}
