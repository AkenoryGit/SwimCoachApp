//
//  TrainingUpdateNotifier.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import Foundation
import CoreData

//Это объявление класса TrainingUpdateNotifier, который может быть замечен SwiftUI как наблюдаемый объект (ObservableObject). Это значит, что другие части интерфейса могут «подписаться» на него и реагировать, когда что-то меняется внутри.
class TrainingUpdateNotifier: ObservableObject {
    
//    Это делает класс “одиночкой” (singleton) — можно будет обращаться к нему откуда угодно через TrainingUpdateNotifier.shared.
    static let shared = TrainingUpdateNotifier()
    
//    Это переменная, которая говорит SwiftUI, что произошли изменения. Когда она меняется, интерфейс, подписанный на этот объект, обновляется.
    @Published var didChange = false

//    Это закрытый инициализатор. Благодаря ему нельзя создать второй экземпляр этого класса — только один, через shared.
    private init() {}

//    Этот метод просто переключает значение didChange с false на true или наоборот. Это сигнал для интерфейса: «данные обновились, перерисуй экран!»
    func notifyUpdate() {
        didChange.toggle()
    }

//    Этот метод проверяет тренировки в базе и обновляет их статус, если они уже прошли. Принимает контекст Core Data.
    func updateStatusesIfNeeded(context: NSManagedObjectContext) {
        
//        Создаём запрос к базе данных, чтобы получить все объекты типа Training.
        let request: NSFetchRequest<Training> = Training.fetchRequest()
        
//        Указываем условие: ищем только те тренировки, которые «Запланированы».
        request.predicate = NSPredicate(format: "status == %@", "Запланирована")

//        Пытаемся загрузить эти тренировки из базы. Также сохраняем текущую дату-время.
        do {
            let scheduledTrainings = try context.fetch(request)
            let now = Date()

//            Для каждой запланированной тренировки проверяем: если она уже закончилась (время окончания endTime раньше текущего времени), и если она сегодня или раньше — меняем её статус на «Проведена».
            for training in scheduledTrainings {
                if let endTime = training.endTime,
                   let date = training.date,
                   endTime < now,
                   Calendar.current.isDate(date, inSameDayAs: now) || date < now {
                    
                    training.status = "Проведена"
                }
            }

//            Если были изменения — сохраняем их в базу и говорим, что данные обновились, чтобы интерфейс перерисовался.
            if context.hasChanges {
                try context.save()
                self.didChange.toggle()
            }
            
//            Если что-то пошло не так (например, не удалось сохранить) — выводим ошибку в консоль.
        } catch {
            print("Ошибка при обновлении статусов: \(error.localizedDescription)")
        }
    }
}
