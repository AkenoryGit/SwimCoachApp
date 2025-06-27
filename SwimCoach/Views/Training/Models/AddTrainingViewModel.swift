//
//  AddTrainingViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - ViewModel для создания новой тренировки или дежурства

final class AddTrainingViewModel: ObservableObject {

    // MARK: - Опубликованные свойства для привязки к UI

    @Published var selectedTrainer: Trainer? = nil
    @Published var showTimeErrorAlert = false
    @Published var timeErrorMessage = ""

    // Дата и время начала тренировки/дежурства
    @Published var date: Date = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: Date()),
                                                      minute: 0,
                                                      second: 0,
                                                      of: Date()) ?? Date()

    // Время окончания тренировки/дежурства
    @Published var endTime: Date = Calendar.current.date(byAdding: .minute, value: 50, to: Date()) ?? Date()

    // Тип создаваемой записи (тренировка или дежурство)
    @Published var entryType: EntryType = .training

    // Выбранный тип тренировки (персональная, групповая и т.д.)
    @Published var selectedType: TrainingType = .personal

    // Место проведения тренировки
    @Published var selectedLocation: TrainingLocation = .bigPool

    // Статус тренировки (запланирована, проведена и т.д.)
    @Published var status: String = "Запланирована"

    // Комментарий к записи
    @Published var note: String = ""

    // Множество выбранных клиентов (по ID)
    @Published var selectedClients: Set<UUID> = []

    // MARK: - Методы взаимодействия

    /// Переключение клиента в списке выбранных
    func toggleClientSelection(_ client: Client) {
        guard let id = client.id else { return }
        if selectedClients.contains(id) {
            selectedClients.remove(id)
        } else {
            selectedClients.insert(id)
        }
    }

    /// Расчёт окончания тренировки на основе типа и времени начала
    func calculateEndTime(for type: String?, startDate: Date) -> Date {
        let duration: Int
        switch type {
        case "Групповая (ББ)", "ПТ дети (ББ)", "Мини-группа (ББ)", "Сплит (ББ)":
            duration = 50
        case "Групповая (ДБ)", "СПТ", "Сплит (ДБ)", "Мини-группа (ДБ)", "ПТ (ДБ)":
            duration = 45
        case "Грудничковое плавание":
            duration = 30
        case "ПТ взрослый (ББ)":
            duration = 55
        default:
            duration = 50
        }
        return Calendar.current.date(byAdding: .minute, value: duration, to: startDate) ?? startDate
    }

    // MARK: - Сохранение данных в Core Data

    /// Сохраняет тренировку или дежурство в базу данных
    func saveTraining(context: NSManagedObjectContext,
                      activeClients: FetchedResults<Client>,
                      dismiss: @escaping () -> Void) {

        let calendar = Calendar.current
        
        guard date < endTime else {
            timeErrorMessage = "Время начала не может быть позже или равно времени окончания"
            showTimeErrorAlert = true
            return
        }

        // Если создаётся дежурство
        if entryType == .duty {
            let newDuty = Duty(context: context)
            let day = calendar.startOfDay(for: date)

            let startHour = calendar.component(.hour, from: date)
            let startMinute = calendar.component(.minute, from: date)
            let endHour = calendar.component(.hour, from: endTime)
            let endMinute = calendar.component(.minute, from: endTime)

            newDuty.startTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: day)
            newDuty.id = UUID()
            newDuty.endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: day)
            newDuty.note = note
            newDuty.trainerName = selectedTrainer?.fullName
            newDuty.status = status

            do {
                try context.save()
                dismiss()
            } catch {
                print("Ошибка при сохранении дежурства: \(error.localizedDescription)")
            }
            return
        }

        // Если создаётся тренировка
        let newTraining = Training(context: context)
        newTraining.id = UUID()
        newTraining.date = date
        newTraining.endTime = endTime
        newTraining.type = selectedType.rawValue
        newTraining.location = selectedLocation.rawValue
        newTraining.status = status
        newTraining.note = note

        // Привязка клиентов к тренировке и списание занятий
        for client in activeClients {
            guard let clientID = client.id else { continue }

            if selectedClients.contains(clientID) {
                newTraining.addToClients(client)

                if status == "Проведена",
                   let balances = client.balances as? Set<TrainingBalance>,
                   let balance = balances.first(where: { $0.type == selectedType.rawValue && $0.count > 0 }) {
                    balance.count -= 1
                }
            }
        }

        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка при сохранении тренировки: \(error.localizedDescription)")
        }
    }
    
    // Загрузка существующей тренировки
    func loadTraining(id: UUID, context: NSManagedObjectContext) {
        let request: NSFetchRequest<Training> = Training.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let training = try? context.fetch(request).first {
            self.entryType = .training
            self.date = training.date ?? Date()
            self.endTime = training.endTime ?? Date()
            self.selectedType = TrainingType(rawValue: training.type ?? "") ?? .personal
            self.selectedLocation = TrainingLocation(rawValue: training.location ?? "") ?? .bigPool
            self.status = training.status ?? "Запланирована"
            self.note = training.note ?? ""
            self.selectedClients = Set(training.clientsArray.map { $0.id ?? UUID() })
        }
    }

    // Сохранение обновлений
    func updateTraining(id: UUID, context: NSManagedObjectContext, activeClients: FetchedResults<Client>, onSave: @escaping () -> Void) {
        let request: NSFetchRequest<Training> = Training.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let training = try? context.fetch(request).first else { return }

        training.date = self.date
        training.endTime = self.endTime
        training.type = self.selectedType.rawValue
        training.location = self.selectedLocation.rawValue
        training.status = self.status
        training.note = self.note

        training.clients = NSSet(array: activeClients.filter { self.selectedClients.contains($0.id ?? UUID()) })

        do {
            try context.save()
            onSave()
        } catch {
            print("❌ Не удалось сохранить изменения: \(error)")
        }
    }
}
