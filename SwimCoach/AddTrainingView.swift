//
//  AddTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

struct Trainer: Identifiable, Hashable {
    let id: UUID
    let fullName: String
}

let mockTrainers: [Trainer] = [
    Trainer(id: UUID(), fullName: "Дмитрий Дудник"),
    Trainer(id: UUID(), fullName: "Иванов Иван"),
    Trainer(id: UUID(), fullName: "Петров Пётр")
]

enum NewEntryType: String, CaseIterable, Identifiable {
    case training = "Тренировка"
    case duty = "Дежурство"

    var id: String { rawValue }
}

struct AddTrainingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTrainer: Trainer? = nil
    private let allTrainers = mockTrainers

    // Дата и время тренировки
    @State private var date: Date = {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        return calendar.date(from: components) ?? now
    }()
    @State private var endTime: Date = {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        let rounded = calendar.date(from: components) ?? now
        return calendar.date(byAdding: .minute, value: 50, to: rounded) ?? now
    }()
    
    @State private var entryType: NewEntryType = .training

    // Тип тренировки (по умолчанию — персоналка)
    @State private var selectedType: TrainingType = .personal

    // Статус тренировки: Запланирована, Проведена, Отменена
    @State private var status = "Запланирована"

    // Текст заметки к тренировке
    @State private var note = ""

    // Выбранные клиенты (сохраняются по ID)
    @State private var selectedClients: Set<UUID> = []

    // Загружаем всех клиентов из базы
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    )
    private var activeClients: FetchedResults<Client>

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тип записи")) {
                    Picker("Тип", selection: $entryType) {
                        Text("Тренировка").tag(NewEntryType.training)
                        Text("Дежурство").tag(NewEntryType.duty)
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Дата и тип")) {
                    if entryType == .duty {
                        Section(header: Text("Дежурство за")) {
                            Picker("Тренер", selection: $selectedTrainer) {
                                ForEach(allTrainers, id: \.self) { trainer in
                                    Text(trainer.fullName).tag(trainer as Trainer?)
                                }
                            }
                        }
                    }
                    DatePicker("Дата и время", selection: $date)
                        .onChange(of: date) { newDate in
                            endTime = calculateEndTime(for: selectedType.rawValue, startDate: newDate)
                        }
                    DatePicker("Окончание", selection: $endTime)
                    if entryType == .training {
                        Picker("Тип тренировки", selection: $selectedType) {
                            ForEach(TrainingType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .onChange(of: selectedType) { newType in
                            endTime = calculateEndTime(for: newType.rawValue, startDate: date)
                        }
                    }
                    Picker("Статус", selection: $status) {
                        Text("Запланирована").tag("Запланирована")
                        Text("Проведена").tag("Проведена")
                        Text("Отменена").tag("Отменена")
                    }
                }

                if entryType == .training {
                    Section(header: Text("Клиенты")) {
                        ForEach(activeClients) { client in
                            MultipleSelectionRow(
                                title: client.fullName ?? "Без имени",
                                isSelected: selectedClients.contains(client.id ?? UUID())
                            ) {
                                toggleClientSelection(client)
                            }
                        }
                    }
                }

                Section(header: Text("Заметка")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
            }
            .onAppear {
                endTime = calculateEndTime(for: selectedType.rawValue, startDate: date)
            }
            .navigationTitle("Новая тренировка")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveTraining()
                        dismiss()
                    }
                    .disabled(entryType == .training && selectedClients.isEmpty)
                }
            }
        }
    }

    // MARK: — Переключение клиента
    private func toggleClientSelection(_ client: Client) {
        guard let id = client.id else { return }

        print("Выбран клиент: \(client.fullName ?? "Без имени"), ID: \(id), удалён? \(client.isDeletedClient ? "Да" : "Нет")")

        if selectedClients.contains(id) {
            selectedClients.remove(id)
        } else {
            selectedClients.insert(id)
        }
    }

    // MARK: — Сохранение тренировки
    private func saveTraining() {
        if entryType == .duty {
            let newDuty = Duty(context: viewContext)

            let calendar = Calendar.current
            let timezone = TimeZone.current

            // Формируем компоненты даты и времени с учетом локальной временной зоны
            let day = calendar.startOfDay(for: date)

            let startHour = calendar.component(.hour, from: date)
            let startMinute = calendar.component(.minute, from: date)

            let endHour = calendar.component(.hour, from: endTime)
            let endMinute = calendar.component(.minute, from: endTime)

            newDuty.startTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: day)
            newDuty.endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: day)

            // Остальные поля
            newDuty.note = note
            newDuty.trainerName = selectedTrainer?.fullName
            newDuty.status = status

            do {
                try viewContext.save()
                print("🕒 FINAL startTime:", newDuty.startTime ?? .distantPast)
                print("🕒 FINAL endTime:", newDuty.endTime ?? .distantPast)
                print("🟠 СОХРАНЕНО ДЕЖУРСТВО: \(newDuty.startTime ?? .distantPast) — \(newDuty.endTime ?? .distantFuture)")
            } catch {
                print("Ошибка при сохранении дежурства: \(error.localizedDescription)")
            }

            return
        }

        // Только если это тренировка
        let newTraining = Training(context: viewContext)
        newTraining.id = UUID()
        newTraining.date = date
        newTraining.endTime = endTime
        newTraining.type = selectedType.rawValue
        newTraining.status = status
        newTraining.note = note

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
            try viewContext.save()
        } catch {
            print("Ошибка при сохранении тренировки: \(error.localizedDescription)")
        }
    }
    
    private func calculateEndTime(for type: String?, startDate: Date) -> Date {
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

}
