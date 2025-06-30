////
////  AddTrainingViewModel.swift
////  SwimCoach
////
////  Created by Дмитрий Дудник on 24.06.2025.
////
//
//import Foundation
//import SwiftUI
//import CoreData
//
//// MARK: - ViewModel для создания новой тренировки или дежурства
//
//final class AddTrainingViewModel: ObservableObject {
//
//    // MARK: - Опубликованные свойства для привязки к UI
//
//    @Published var selectedTrainer: CoachData? = nil
//    @Published var showTimeErrorAlert = false
//    @Published var timeErrorMessage = ""
//    @Published var showAllClients: Bool = false
//
//    @Published var date: Date = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: Date()),
//                                                      minute: 0,
//                                                      second: 0,
//                                                      of: Date()) ?? Date()
//
//    @Published var endTime: Date = Calendar.current.date(byAdding: .minute, value: 50, to: Date()) ?? Date()
//    @Published var entryType: EntryType = .training
//    @Published var selectedType: TrainingType = .personal
//    @Published var selectedLocation: TrainingLocation = .bigPool
//    @Published var status: String = "Запланирована"
//    @Published var note: String = ""
//    @Published var selectedClients: Set<UUID> = []
//    @Published var clientSearchText: String = ""
//    @Published var showAllTrainers: Bool = false
//    @Published var trainerSearchText: String = ""
//
//    // MARK: - Методы взаимодействия
//
//    func filteredTrainers(from trainers: FetchedResults<CoachData>) -> [CoachData] {
//        if trainerSearchText.isEmpty {
//            return Array(trainers)
//        } else {
//            return trainers.filter {
//                $0.fullName?.localizedCaseInsensitiveContains(trainerSearchText) ?? false
//            }
//        }
//    }
//
//    func filteredClients(from allClients: FetchedResults<Client>) -> [Client] {
//        if clientSearchText.isEmpty {
//            return Array(allClients)
//        } else {
//            return allClients.filter {
//                $0.fullName?.localizedCaseInsensitiveContains(clientSearchText) ?? false
//            }
//        }
//    }
//
//    func toggleClientSelection(_ id: UUID) {
//        if selectedClients.contains(id) {
//            selectedClients.remove(id)
//        } else {
//            selectedClients.insert(id)
//        }
//    }
//
//    func calculateEndTime(for type: String?, startDate: Date) -> Date {
//        let duration: Int
//        switch type {
//        case "Групповая (ББ)", "ПТ дети (ББ)", "Мини-группа (ББ)", "Сплит (ББ)":
//            duration = 50
//        case "Групповая (ДБ)", "СПТ", "Сплит (ДБ)", "Мини-группа (ДБ)", "ПТ (ДБ)":
//            duration = 45
//        case "Грудничковое плавание":
//            duration = 30
//        case "ПТ взрослый (ББ)":
//            duration = 55
//        default:
//            duration = 50
//        }
//        return Calendar.current.date(byAdding: .minute, value: duration, to: startDate) ?? startDate
//    }
//
//    // MARK: - Сохранение данных в Core Data
//
//    @MainActor
//    func saveTraining(context: NSManagedObjectContext,
//                      activeClients: FetchedResults<Client>,
//                      activeTrainers: FetchedResults<CoachData>,
//                      dismiss: @escaping () -> Void) {
//
//        let calendar = Calendar.current
//
//        guard date < endTime else {
//            timeErrorMessage = "Время начала не может быть позже или равно времени окончания"
//            showTimeErrorAlert = true
//            return
//        }
//
//        if entryType == .duty {
//            let fetchRequest: NSFetchRequest<Duty> = Duty.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "(startTime < %@) AND (endTime > %@)", endTime as CVarArg, date as CVarArg)
//
//            do {
//                let overlappingDuties = try context.fetch(fetchRequest)
//                if !overlappingDuties.isEmpty {
//                    self.timeErrorMessage = "Это дежурство пересекается по времени с другим дежурством."
//                    self.showTimeErrorAlert = true
//                    return
//                }
//            } catch {
//                print("Ошибка при проверке пересечений дежурств: \(error.localizedDescription)")
//            }
//
//            let newDuty = Duty(context: context)
//            newDuty.id = UUID()
//            newDuty.startTime = date
//            newDuty.endTime = endTime
//            newDuty.note = note
//            newDuty.trainerName = selectedTrainer?.fullName
//            newDuty.status = status
//
//            do {
//                try context.save()
//                dismiss()
//            } catch {
//                print("Ошибка при сохранении дежурства: \(error.localizedDescription)")
//            }
//
//            return
//        }
//
//        let newTraining = Training(context: context)
//        newTraining.id = UUID()
//        newTraining.date = date
//        newTraining.endTime = endTime
//        newTraining.type = selectedType.rawValue
//        newTraining.location = selectedLocation.rawValue
//        newTraining.status = status
//        newTraining.note = note
//
//        for client in activeClients {
//            guard let clientID = client.id else { continue }
//
//            if selectedClients.contains(clientID) {
//                newTraining.addToClients(client)
//
//                if status == "Проведена",
//                   let balances = client.balances as? Set<TrainingBalance>,
//                   let balance = balances.first(where: { $0.type == selectedType.rawValue && $0.count > 0 }) {
//                    balance.count -= 1
//                }
//            }
//        }
//
//        do {
//            try context.save()
//            dismiss()
//        } catch {
//            print("Ошибка при сохранении тренировки: \(error.localizedDescription)")
//        }
//    }
//
//    func loadTraining(id: UUID, context: NSManagedObjectContext) {
//        let request: NSFetchRequest<Training> = Training.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//        if let training = try? context.fetch(request).first {
//            self.entryType = .training
//            self.date = training.date ?? Date()
//            self.endTime = training.endTime ?? Date()
//            self.selectedType = TrainingType(rawValue: training.type ?? "") ?? .personal
//            self.selectedLocation = TrainingLocation(rawValue: training.location ?? "") ?? .bigPool
//            self.status = training.status ?? "Запланирована"
//            self.note = training.note ?? ""
//            self.selectedClients = Set(training.clientsArray.map { $0.id ?? UUID() })
//        }
//    }
//
//    func updateTraining(id: UUID, context: NSManagedObjectContext, activeClients: FetchedResults<Client>, onSave: @escaping () -> Void) {
//        let request: NSFetchRequest<Training> = Training.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//        guard let training = try? context.fetch(request).first else { return }
//
//        training.date = self.date
//        training.endTime = self.endTime
//        training.type = self.selectedType.rawValue
//        training.location = self.selectedLocation.rawValue
//        training.status = self.status
//        training.note = self.note
//
//        training.clients = NSSet(array: activeClients.filter { self.selectedClients.contains($0.id ?? UUID()) })
//
//        do {
//            try context.save()
//            onSave()
//        } catch {
//            print("❌ Не удалось сохранить изменения: \(error)")
//        }
//    }
//}
