//
//  DeletedClientsViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import Foundation
import CoreData

// Этот файл содержит ViewModel для управления удаленными клиентами в приложении SwimCoach.
class DeletedClientsViewModel: ObservableObject {
    @Published var selectedAction: ClientActionType? // текущий выбранный тип действия
    @Published var refreshTrigger = false // триггер для обновления списка

    func restore(_ client: Client, context: NSManagedObjectContext) { // восстановление удаленного клиента
        client.isDeletedClient = false // устанавливаем флаг удаления
        save(context) // сохраняем изменения в контексте
    }

    func permanentlyDelete(_ client: Client, context: NSManagedObjectContext) { // окончательное удаление клиента
        context.delete(client) // удаляем объект из контекста
        save(context) // сохраняем изменения
    }

    private func save(_ context: NSManagedObjectContext) { // функция сохранения изменений в контексте
        do { // сохраняем изменения
            try context.save() // вызываем метод save контекста
            refreshTrigger.toggle() // переключаем триггер обновления
        } catch { // обрабатываем возможные ошибки
            print("Ошибка при сохранении: \(error.localizedDescription)") // выводим сообщение об ошибке в консоль
        }
    }
}
