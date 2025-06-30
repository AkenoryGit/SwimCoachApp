//
//  EntryViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 30.06.2025.
//

import Foundation
import SwiftUI
import CoreData

enum EntryMode {
    case create
    case edit
}

enum EntryCategory {
    case training
    case duty
}

final class EntryViewModel: ObservableObject {

    // MARK: - Входные параметры
    let mode: EntryMode

    // MARK: - CoreData объект (для режима редактирования)
    private var existingTraining: Training?
    private var existingDuty: Duty?

    // MARK: - Общие свойства
    @Published var date: Date = Date() {
        didSet {
            updateEndTime()
        }
    }
    @Published var endTime: Date = Date().addingTimeInterval(60 * 50)
    @Published var note: String = ""
    @Published var status: String = "Запланирована"
    @Published var category: EntryCategory

    // MARK: - Тренировка
    @Published var selectedType: TrainingType = .personal
    @Published var selectedLocation: TrainingLocation = .bigPool
    @Published var selectedClients: Set<UUID> = []
    @Published var clientSearchText: String = ""
    @Published var showAllClients: Bool = false
    @Published var selectedDuration: Int = 50 {
        didSet {
            updateEndTime()
        }
    }
    
    // Массив возможных длительностей, можно менять при необходимости
    let possibleDurations = [30, 45, 50, 55]

    // MARK: - Дежурство
    @Published var selectedTrainer: CoachData? = nil
    @Published var trainerSearchText: String = ""
    @Published var showAllTrainers: Bool = false

    // MARK: - Ошибки
    @Published var showTimeErrorAlert: Bool = false
    @Published var timeErrorMessage: String = ""

    // MARK: - Инициализация для создания
    init(category: EntryCategory) {
        self.mode = .create
        self.category = category
    }

    // MARK: - Инициализация для редактирования тренировки
    init(training: Training) {
        self.mode = .edit
        self.category = .training
        self.existingTraining = training
        self.selectedDuration = Int(training.endTime?.timeIntervalSince(training.date ?? Date()) ?? 3000) / 60

        self.date = training.date ?? Date()
        self.endTime = training.endTime ?? Date().addingTimeInterval(60 * 50)
        self.note = training.note ?? ""
        self.status = training.status ?? "Запланирована"
        self.selectedType = TrainingType(rawValue: training.type ?? "") ?? .personal
        self.selectedLocation = TrainingLocation(rawValue: training.location ?? "") ?? .bigPool
        if let clients = training.clients as? Set<Client> {
            self.selectedClients = Set(clients.compactMap { $0.id })
        }
        setupBindings()
    }
    
    init(category: EntryCategory, initialDate: Date = Date()) {
        self.mode = .create
        self.category = category
        self.date = initialDate
        updateDefaultDuration()
        updateEndTime()
    }

    // MARK: - Инициализация для редактирования дежурства
    init(duty: Duty) {
        self.mode = .edit
        self.category = .duty
        self.existingDuty = duty

        self.date = duty.startTime ?? Date()
        self.endTime = duty.endTime ?? Date().addingTimeInterval(60 * 50)
        self.note = duty.note ?? ""
        self.status = duty.status ?? "Запланирована"
        // Для дежурства указываем только тренера
        // selectedTrainer должен быть установлен снаружи после инициализации
    }

    // MARK: - Методы фильтрации, валидации, сохранения и обновления
    // Фильтрация клиентов по поисковому тексту
    func filteredClients(from allClients: FetchedResults<Client>) -> [Client] {
        if clientSearchText.isEmpty {
            return Array(allClients)
        } else {
            return allClients.filter {
                $0.fullName?.localizedCaseInsensitiveContains(clientSearchText) ?? false
            }
        }
    }
    
    private func updateEndTime() {
        endTime = date.addingTimeInterval(TimeInterval(selectedDuration * 60))
    }
    
    private func setupBindings() {
        // Можно использовать Combine, либо через didSet, либо через @Published sink (если подключен Combine)
        // Для простоты сделаем через didSet в свойствах (потом, если хочешь, можно сделать через Combine)

        // При изменении date или selectedDuration обновлять endTime
    }
    
    func updateDefaultDuration() {
        // Логика выбора длительности по типу и локации
        if category == .training {
            switch selectedType {
            case .personal:
                selectedDuration = (selectedLocation == .bigPool) ? 50 : 45
            case .infant:
                if selectedLocation == .smallPool {
                    selectedDuration = 30
                }
            case .startingTraining:
                selectedDuration = 45
            default:
                selectedDuration = 50
            }
        }
    }

    // Добавим методы для обновления при изменении date и selectedDuration

    func onDateChanged(to newDate: Date) {
        date = newDate
        updateEndTime()
    }

    func onDurationChanged(to newDuration: Int) {
        selectedDuration = newDuration
        updateEndTime()
    }

    func onTypeOrLocationChanged(type: TrainingType, location: TrainingLocation) {
        selectedType = type
        selectedLocation = location
        updateDefaultDuration()
        updateEndTime()
    }

    // Фильтрация тренеров по поисковому тексту
    func filteredTrainers(from allTrainers: FetchedResults<CoachData>) -> [CoachData] {
        if trainerSearchText.isEmpty {
            return Array(allTrainers)
        } else {
            return allTrainers.filter {
                $0.fullName?.localizedCaseInsensitiveContains(trainerSearchText) ?? false
            }
        }
    }

    // Переключение выбора клиента
    func toggleClientSelection(_ id: UUID) {
        if selectedClients.contains(id) {
            selectedClients.remove(id)
        } else {
            selectedClients.insert(id)
        }
    }

}

extension EntryViewModel {

    func validateTime(minDurationMinutes: Int = 20) -> Bool {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: date)
        let endHour = calendar.component(.hour, from: endTime)
        let duration = endTime.timeIntervalSince(date)

        if startHour < 6 || endHour > 23 {
            timeErrorMessage = "Время должно быть между 06:00 и 23:00"
            showTimeErrorAlert = true
            return false
        }

        if date >= endTime {
            timeErrorMessage = "Время начала не может быть позже или равно времени окончания"
            showTimeErrorAlert = true
            return false
        }

        if duration < Double(minDurationMinutes * 60) {
            timeErrorMessage = "Минимальная длительность — \(minDurationMinutes) минут"
            showTimeErrorAlert = true
            return false
        }

        return true
    }

    @MainActor
    func save(context: NSManagedObjectContext,
              activeClients: FetchedResults<Client>,
              activeTrainers: FetchedResults<CoachData>,
              dismiss: @escaping () -> Void) {

        guard validateTime() else { return }

        switch (mode, category) {
        case (.create, .training):
            saveNewTraining(context: context, activeClients: activeClients, dismiss: dismiss)
        case (.edit, .training):
            updateTraining(context: context, activeClients: activeClients, dismiss: dismiss)
        case (.create, .duty):
            saveNewDuty(context: context, activeTrainers: activeTrainers, dismiss: dismiss)
        case (.edit, .duty):
            updateDuty(context: context, activeTrainers: activeTrainers, dismiss: dismiss)
        }
    }

    private func saveNewTraining(context: NSManagedObjectContext,
                                 activeClients: FetchedResults<Client>,
                                 dismiss: @escaping () -> Void) {
        let training = Training(context: context)
        training.id = UUID()
        training.date = date
        training.endTime = endTime
        training.type = selectedType.rawValue
        training.location = selectedLocation.rawValue
        training.status = status
        training.note = note

        // Добавляем клиентов, если есть выбранные
        for client in activeClients where selectedClients.contains(client.id ?? UUID()) {
            training.addToClients(client)
            if status == "Проведена",
               let balances = client.balances as? Set<TrainingBalance>,
               let balance = balances.first(where: { $0.type == selectedType.rawValue && $0.count > 0 }) {
                balance.count -= 1
            }
        }

        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка при сохранении тренировки: \(error)")
        }
    }

    private func updateTraining(context: NSManagedObjectContext,
                                activeClients: FetchedResults<Client>,
                                dismiss: @escaping () -> Void) {
        guard let training = existingTraining else { return }

        training.date = date
        training.endTime = endTime
        training.type = selectedType.rawValue
        training.location = selectedLocation.rawValue
        training.status = status
        training.note = note

        training.removeFromClients(training.clients ?? [])

        // Просто добавляем выбранных клиентов, если они есть
        for client in activeClients where selectedClients.contains(client.id ?? UUID()) {
            training.addToClients(client)
        }

        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка при обновлении тренировки: \(error)")
        }
    }

    private func saveNewDuty(context: NSManagedObjectContext,
                             activeTrainers: FetchedResults<CoachData>,
                             dismiss: @escaping () -> Void) {
        let duty = Duty(context: context)
        duty.id = UUID()
        duty.startTime = date
        duty.endTime = endTime
        duty.note = note
        duty.status = status
        duty.trainerName = selectedTrainer?.fullName

        // Проверка пересечений дежурств
        let fetchRequest: NSFetchRequest<Duty> = Duty.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(startTime < %@) AND (endTime > %@)", endTime as CVarArg, date as CVarArg)

        do {
            let overlapping = try context.fetch(fetchRequest)
            if !overlapping.isEmpty {
                timeErrorMessage = "Это дежурство пересекается по времени с другим дежурством."
                showTimeErrorAlert = true
                return
            }
            try context.save()
            dismiss()
        } catch {
            print("Ошибка при сохранении дежурства: \(error)")
        }
    }

    private func updateDuty(context: NSManagedObjectContext,
                            activeTrainers: FetchedResults<CoachData>,
                            dismiss: @escaping () -> Void) {
        guard let duty = existingDuty else { return }

        // Проверка пересечений дежурств, исключая текущее дежурство
        let fetchRequest: NSFetchRequest<Duty> = Duty.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "(startTime < %@) AND (endTime > %@)", endTime as CVarArg, date as CVarArg),
            NSPredicate(format: "id != %@", duty.id! as CVarArg)
        ])

        do {
            let overlapping = try context.fetch(fetchRequest)
            if !overlapping.isEmpty {
                timeErrorMessage = "Это дежурство пересекается по времени с другим дежурством."
                showTimeErrorAlert = true
                return
            }

            duty.startTime = date
            duty.endTime = endTime
            duty.note = note
            duty.status = status
            duty.trainerName = selectedTrainer?.fullName

            try context.save()
            dismiss()
        } catch {
            print("Ошибка при обновлении дежурства: \(error)")
        }
    }
}
