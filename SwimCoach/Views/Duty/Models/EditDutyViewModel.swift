//
//  EditDutyViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 18.06.2025.
//

import Foundation
import SwiftUI
import CoreData

/// ViewModel для редактирования существующего дежурства
final class EditDutyViewModel: ObservableObject {

    // MARK: - Входные данные
    let duty: Duty
    let coaches: FetchedResults<CoachData>

    // MARK: - Опубликованные свойства для UI
    @Published var note: String
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var selectedTrainer: CoachData?
    @Published var selectedStatus: String
    @Published var trainerSearchText: String = ""
    @Published var showAllTrainers: Bool = false
    @Published var showTimeErrorAlert: Bool = false
    @Published var timeErrorMessage: String = ""

    // MARK: - Константы
    let allStatuses = ["Запланирована", "Проведена"]

    // MARK: - Инициализация
    init(duty: Duty, coaches: FetchedResults<CoachData>) {
        self.duty = duty
        self.coaches = coaches
        self.note = duty.note ?? ""
        self.selectedStatus = duty.status ?? "Запланирована"
        self.startTime = duty.startTime ?? Date()
        self.endTime = duty.endTime ?? Date().addingTimeInterval(3600)
        if let name = duty.trainerName {
            self.selectedTrainer = coaches.first { $0.fullName == name }
        }
    }

    // MARK: - Фильтрация тренеров
    func filteredTrainers() -> [CoachData] {
        if trainerSearchText.isEmpty {
            return Array(coaches)
        } else {
            return coaches.filter {
                $0.fullName?.localizedCaseInsensitiveContains(trainerSearchText) ?? false
            }
        }
    }

    // MARK: - Сохранение дежурства
    func save(context: NSManagedObjectContext, onComplete: @escaping () -> Void) {
        // Проверка на пересечение дежурств (исключаем текущее)
        let fetchRequest: NSFetchRequest<Duty> = Duty.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id != %@ AND startTime < %@ AND endTime > %@", duty.id! as CVarArg, endTime as CVarArg, startTime as CVarArg)

        do {
            let overlaps = try context.fetch(fetchRequest)
            if !overlaps.isEmpty {
                Task { @MainActor in
                    self.timeErrorMessage = "Это дежурство пересекается по времени с другим дежурством."
                    self.showTimeErrorAlert = true
                }
                return
            }

            duty.startTime = startTime
            duty.endTime = endTime
            duty.status = selectedStatus
            duty.note = note
            duty.trainerName = selectedTrainer?.fullName

            try context.save()
            onComplete()

        } catch {
            print("❌ Ошибка при сохранении дежурства: \(error)")
        }
    }

    // MARK: - Удаление дежурства
    func delete(context: NSManagedObjectContext, dismiss: @escaping () -> Void) {
        context.delete(duty)
        do {
            try context.save()
            dismiss()
        } catch {
            print("❌ Ошибка при удалении дежурства: \(error.localizedDescription)")
        }
    }
}
