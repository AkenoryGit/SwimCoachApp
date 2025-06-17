//
//  Persistence.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import CoreData

// Этот файл отвечает за настройку системы хранения данных (Core Data).
// Core Data позволяет сохранять тренировки, дежурства и другую информацию между запусками приложения.

// Структура PersistenceController — это "менеджер" базы данных.
// Внутри она создаёт контейнер (NSPersistentContainer), который управляет базой данных.
struct PersistenceController {
    // static let shared = PersistenceController() — это способ сделать этот контроллер доступным из любой части приложения.
    // Например, можно написать PersistenceController.shared, и получить доступ к базе данных.
    static let shared = PersistenceController()

    @MainActor

    let container: NSPersistentContainer

    // init(inMemory: Bool = false) — это инициализация контейнера.
    // Если передать true, данные будут храниться только в памяти (удобно для тестов).
    // Если false — данные сохраняются в файл (то есть — реально сохраняются).
    init(inMemory: Bool = false) {
        // container = NSPersistentContainer(name: "SwimCoach") — создаёт контейнер с именем базы данных "SwimCoach".
        container = NSPersistentContainer(name: "SwimCoach")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // container.loadPersistentStores — запускает загрузку хранилища данных. Если произошла ошибка — вызывается fatalError (это для разработчиков, чтобы поймать проблему).
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Здесь можно заменить реализацию на более подходящую обработку ошибки.
                // fatalError() вызывает лог ошибки и завершает приложение. Не рекомендуется использовать в финальной версии приложения, но может быть полезен во время разработки.

                /*
                 Типичные причины ошибки при загрузке хранилища:
                 * Родительская директория не существует, не может быть создана или запрещает запись.
                 * Хранилище недоступно из-за прав доступа или защиты данных, когда устройство заблокировано.
                 * На устройстве закончилось место.
                 * Не удалось выполнить миграцию хранилища до текущей версии модели.
                 Проверь сообщение об ошибке, чтобы определить, в чём была проблема.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // container.viewContext.automaticallyMergesChangesFromParent = true — это позволяет автоматически обновлять данные в приложении, если что-то поменялось в фоне (например, при сохранении).
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
