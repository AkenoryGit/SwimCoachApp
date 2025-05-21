//
//  TrainingUpdateNotifier.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import Foundation
import CoreData

class TrainingUpdateNotifier: ObservableObject {
    static let shared = TrainingUpdateNotifier()
    @Published var didChange = false

    private init() {}

    func notifyUpdate() {
        didChange.toggle()
    }

    func updateStatusesIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Training> = Training.fetchRequest()
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

            if context.hasChanges {
                try context.save()
                self.didChange.toggle()
            }

        } catch {
            print("Ошибка при обновлении статусов: \(error.localizedDescription)")
        }
    }
}
