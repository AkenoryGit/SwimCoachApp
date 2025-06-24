//
//  DayTimelineViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class DayTimelineViewModel: ObservableObject {
    @Published var positionedTrainings: [PositionedTraining] = []
    @Published var positionedDuties: [PositionedDuty] = []
    @Published var nowOffset: CGFloat? = currentTimeOffset()

    private let hourHeight: CGFloat = 60
    private var timerCancellable: AnyCancellable?

    init() {
        // Подписка на обновление текущего времени каждую минуту
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.nowOffset = currentTimeOffset()
            }
    }

    /// Загрузка и позиционирование тренировок и дежурств на выбранную дату
    func fetchData(for date: Date, context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let trainingRequest: NSFetchRequest<Training> = Training.fetchRequest()
        trainingRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Training.date, ascending: true)]
        trainingRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

        let dutyRequest: NSFetchRequest<Duty> = Duty.fetchRequest()
        dutyRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Duty.startTime, ascending: true)]
        dutyRequest.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            let trainings = try context.fetch(trainingRequest)
            let duties = try context.fetch(dutyRequest)

            self.positionedTrainings = calculatePositionedTrainings(from: trainings, hourHeight: hourHeight)
            self.positionedDuties = makePositionedDuties(from: duties, on: date, hourHeight: hourHeight)

        } catch {
            print("❌ Ошибка при загрузке данных: \(error.localizedDescription)")
            self.positionedTrainings = []
            self.positionedDuties = []
        }
    }

    deinit {
        timerCancellable?.cancel()
    }
}
