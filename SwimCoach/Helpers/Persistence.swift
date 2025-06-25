//
//  Persistence.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import CoreData

// MARK: - Контроллер Core Data (хранение данных)

/// Этот файл отвечает за настройку системы хранения данных (Core Data).
/// Core Data позволяет сохранять тренировки, дежурства и другую информацию между запусками приложения.
struct PersistenceController {
    
    /// Синглтон для доступа к базе данных из любой части приложения.
    static let shared = PersistenceController()

    /// Контейнер, управляющий хранилищем Core Data.
    let container: NSPersistentContainer

    /// Инициализация контейнера.
    /// - Parameter inMemory: если `true`, данные сохраняются только в оперативной памяти (удобно для тестов).
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SwimCoach")

        // Настройка на использование памяти вместо диска (для тестов).
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Загрузка хранилища данных
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Возможные причины ошибки:
                 - Недоступна директория
                 - Недостаточно прав
                 - Нет места на устройстве
                 - Ошибка миграции модели
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Автоматическое применение изменений из фоновых потоков.
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
