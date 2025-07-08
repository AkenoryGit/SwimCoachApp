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

enum RecurrenceEditMode {
    case thisOnly
    case thisAndFollowing
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
    @Published var repeatFrequency: RepeatFrequency? = nil
    @Published var recurrenceEditMode: RecurrenceEditMode = .thisOnly

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
    init(training: Training, recurrenceEditMode: RecurrenceEditMode = .thisOnly) {
        self.recurrenceEditMode = recurrenceEditMode
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
        if let freq = training.repeatFrequencyEnum, training.repeatGroupID != nil {
            self.repeatFrequency = freq
        } else {
            self.repeatFrequency = nil
        }
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
    init(duty: Duty, recurrenceEditMode: RecurrenceEditMode = .thisOnly) {
        self.recurrenceEditMode = recurrenceEditMode
        self.mode = .edit
        self.category = .duty
        self.existingDuty = duty

        self.date = duty.startTime ?? Date()
        self.endTime = duty.endTime ?? Date().addingTimeInterval(60 * 50)
        self.note = duty.note ?? ""
        self.status = duty.status ?? "Запланирована"
        if let rawValue = duty.repeatFrequency,
           let freq = RepeatFrequency(rawValue: rawValue),
           duty.repeatGroupID != nil {
            self.repeatFrequency = freq
        } else {
            self.repeatFrequency = nil
        }
        self.selectedTrainer = duty.coach
        // selectedTrainer — устанавливается снаружи после инициализации
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

        switch category {
        case .training:
            upsertEntry(
                existingObject: existingTraining,
                entityName: "Training",
                recurrenceKey: "date",
                repeatFrequency: repeatFrequency,
                recurrenceEditMode: recurrenceEditMode,
                context: context,
                dismiss: dismiss,
                configure: { training in
                    training.setValue(self.date, forKey: "date")
                    training.setValue(self.endTime, forKey: "endTime")
                    training.setValue(self.status, forKey: "status")
                    training.setValue(self.note, forKey: "note")
                    training.setValue(self.selectedType.rawValue, forKey: "type")
                    training.setValue(self.selectedLocation.rawValue, forKey: "location")

                    if let training = training as? Training {
                        training.removeFromClients(training.clients ?? [])
                        for client in activeClients where self.selectedClients.contains(client.id ?? UUID()) {
                            training.addToClients(client)
                        }
                    }
                },
                generateAdditional: { groupID in
                    var result: [Training] = []
                    let calendar = Calendar.current
                    let maxDate = calendar.date(byAdding: .year, value: 1, to: self.date)!
                    var offset = 1

                    while let (nextStart, nextEnd) = self.repeatFrequency?.nextDate(from: self.date, endDate: self.endTime, step: offset),
                          nextStart <= maxDate {

                        let next = Training(context: context)
                        next.id = UUID()
                        next.date = nextStart
                        next.endTime = nextEnd
                        next.status = self.status
                        next.note = self.note
                        next.type = self.selectedType.rawValue
                        next.location = self.selectedLocation.rawValue
                        next.repeatFrequency = self.repeatFrequency?.rawValue
                        next.repeatGroupID = groupID

                        for client in activeClients where self.selectedClients.contains(client.id ?? UUID()) {
                            next.addToClients(client)
                        }

                        result.append(next)
                        offset += 1
                    }

                    return result
                }
            )

        case .duty:
            upsertEntry(
                existingObject: existingDuty,
                entityName: "Duty",
                recurrenceKey: "startTime",
                repeatFrequency: repeatFrequency,
                recurrenceEditMode: recurrenceEditMode,
                context: context,
                dismiss: dismiss,
                checkOverlapRequest: {
                    guard self.recurrenceEditMode != .thisAndFollowing else {
                        return NSFetchRequest<Duty>(entityName: "Duty")
                    }

                    let request: NSFetchRequest<Duty> = Duty.fetchRequest()
                    request.includesPendingChanges = true

                    if let currentID = self.existingDuty?.id {
                        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                            NSPredicate(format: "(startTime < %@) AND (endTime > %@)", self.endTime as CVarArg, self.date as CVarArg),
                            NSPredicate(format: "id != %@", currentID as CVarArg)
                        ])
                    } else {
                        request.predicate = NSPredicate(format: "(startTime < %@) AND (endTime > %@)", self.endTime as CVarArg, self.date as CVarArg)
                    }

                    return request
                },
                configure: { (duty: Duty) in
                    duty.startTime = self.date
                    duty.endTime = self.endTime
                    duty.status = self.status
                    duty.note = self.note
                    duty.trainerName = self.selectedTrainer?.fullName
                    duty.coach = self.selectedTrainer
                },
                generateAdditional: repeatFrequency != nil ? { groupID in
                    var result: [Duty] = []
                    let calendar = Calendar.current
                    let maxDate = calendar.date(byAdding: .year, value: 1, to: self.date)!
                    var offset = 1

                    while let (nextStart, nextEnd) = self.repeatFrequency?.nextDate(from: self.date, endDate: self.endTime, step: offset),
                          nextStart <= maxDate {

                        let next = Duty(context: context)
                        next.id = UUID()
                        next.startTime = nextStart
                        next.endTime = nextEnd
                        next.status = self.status
                        next.note = self.note
                        next.trainerName = self.selectedTrainer?.fullName
                        next.coach = self.selectedTrainer
                        next.repeatFrequency = self.repeatFrequency?.rawValue
                        next.repeatGroupID = groupID

                        result.append(next)
                        offset += 1
                    }

                    return result
                } : nil
            )
        }
    }
    
    func delete(context: NSManagedObjectContext, dismiss: @escaping () -> Void) {
        switch category {
        case .training:
            guard let training = existingTraining else { return }

            deleteEntry(
                objectToDelete: training,
                entityType: Training.self,
                recurrenceKey: "date",
                recurrenceEditMode: recurrenceEditMode,
                context: context,
                dismiss: dismiss
            )

        case .duty:
            guard let duty = existingDuty else { return }

            deleteEntry(
                objectToDelete: duty,
                entityType: Duty.self,
                recurrenceKey: "startTime",
                recurrenceEditMode: recurrenceEditMode,
                context: context,
                dismiss: dismiss
            )
        }
    }
    
    private func deleteEntry<T: NSManagedObject>(
        objectToDelete: T,
        entityType: T.Type,
        recurrenceKey: String,
        recurrenceEditMode: RecurrenceEditMode,
        context: NSManagedObjectContext,
        dismiss: @escaping () -> Void
    ) {
        if recurrenceEditMode == .thisAndFollowing,
           let groupID = objectToDelete.value(forKey: "repeatGroupID") as? UUID,
           let baseDate = objectToDelete.value(forKey: recurrenceKey) as? Date {

            let request = NSFetchRequest<T>(entityName: String(describing: entityType))
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "repeatGroupID == %@", groupID as CVarArg),
                NSPredicate(format: "\(recurrenceKey) >= %@", baseDate as NSDate)
            ])

            do {
                let toDelete = try context.fetch(request)
                toDelete.forEach { context.delete($0) }
            } catch {
                print("❌ Ошибка при удалении повторяющихся объектов \(T.self): \(error)")
            }

        } else {
            context.delete(objectToDelete)
        }

        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка при сохранении после удаления: \(error)")
        }
    }
    
    private func deleteSeries<T: NSManagedObject>(
        of type: T.Type,
        groupID: UUID,
        fieldName: String,
        from date: Date,
        context: NSManagedObjectContext
    ) {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "repeatGroupID == %@", groupID as CVarArg),
            NSPredicate(format: "\(fieldName) > %@", date as NSDate)
        ])

        do {
            let toDelete = try context.fetch(request)
            toDelete.forEach { context.delete($0) }
        } catch {
            print("❌ Ошибка при удалении повторяющихся объектов \(T.self): \(error)")
        }
    }
    
    private func upsertEntry<T: NSManagedObject>(
        existingObject: T?,
        entityName: String,
        recurrenceKey: String,
        repeatFrequency: RepeatFrequency?,
        recurrenceEditMode: RecurrenceEditMode,
        context: NSManagedObjectContext,
        dismiss: @escaping () -> Void,
        checkOverlapRequest: (() -> NSFetchRequest<T>)? = nil,
        configure: @escaping (T) -> Void,
        generateAdditional: ((UUID) -> [T])? = nil
    ) {
        let nowIsRecurring = repeatFrequency != nil
        let isEdit = (existingObject != nil)

        var objectToSave: T

        if isEdit {
            objectToSave = existingObject!
        } else {
            objectToSave = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! T
            if objectToSave.responds(to: Selector(("id"))) {
                objectToSave.setValue(UUID(), forKey: "id")
            }
        }

        // 🔁 Обработка случая "редактировать эту и следующие"
        if isEdit && recurrenceEditMode == .thisAndFollowing {
            if let groupID = objectToSave.value(forKey: "repeatGroupID") as? UUID,
               let baseDate = objectToSave.value(forKey: recurrenceKey) as? Date {
                // ⚠️ Меняем >= на >, чтобы НЕ удалить текущий элемент
                deleteSeries(
                    of: T.self,
                    groupID: groupID,
                    fieldName: recurrenceKey,
                    from: Calendar.current.date(byAdding: .second, value: 1, to: baseDate)!,
                    context: context
                )
            }

            let newGroupID = UUID()
            objectToSave.setValue(newGroupID, forKey: "repeatGroupID")
            objectToSave.setValue(repeatFrequency?.rawValue, forKey: "repeatFrequency")

            configure(objectToSave) // обновляем текущую запись

            if let generate = generateAdditional {
                for item in generate(newGroupID) {
                    context.insert(item)
                }
            }

            configure(objectToSave)
        } else {
            // ✅ Проверка пересечений для обычного редактирования и создания
            if let request = checkOverlapRequest {
                do {
                    let overlaps = try context.fetch(request())
                    print("📋 Найдено пересечений: \(overlaps.count)")
                    for item in overlaps {
                        if let duty = item as? Duty {
                            print("⚠️ Duty ID: \(duty.id?.uuidString ?? "nil"), start: \(duty.startTime ?? Date()), end: \(duty.endTime ?? Date())")
                        }
                    }
                    if !overlaps.isEmpty {
                        self.timeErrorMessage = "Это пересекается по времени с другим элементом"
                        self.showTimeErrorAlert = true
                        return
                    }
                } catch {
                    print("Ошибка проверки пересечений: \(error)")
                }
            }

            let groupID = nowIsRecurring ? UUID() : (objectToSave.value(forKey: "repeatGroupID") as? UUID ?? UUID())

            if nowIsRecurring {
                objectToSave.setValue(groupID, forKey: "repeatGroupID")
                objectToSave.setValue(repeatFrequency?.rawValue, forKey: "repeatFrequency")
            }

            configure(objectToSave)

            if !isEdit && nowIsRecurring {
                if let generate = generateAdditional {
                    for item in generate(groupID) {
                        context.insert(item)
                    }
                }
            }

            if isEdit && recurrenceEditMode == .thisOnly && repeatFrequency == nil {
                if let groupID = objectToSave.value(forKey: "repeatGroupID") as? UUID,
                   let baseDate = objectToSave.value(forKey: recurrenceKey) as? Date {
                    deleteSeries(
                        of: T.self,
                        groupID: groupID,
                        fieldName: recurrenceKey,
                        from: baseDate,
                        context: context
                    )
                    objectToSave.setValue(UUID(), forKey: "repeatGroupID")
                }
                objectToSave.setValue(nil, forKey: "repeatFrequency")
            }
        }

        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка сохранения \(T.self): \(error)")
        }
    }
}

struct EntryData {
    var id: UUID = UUID()
    var start: Date
    var end: Date
    var note: String
    var status: String
    var repeatFrequency: RepeatFrequency?
    var repeatGroupID: UUID?
}
