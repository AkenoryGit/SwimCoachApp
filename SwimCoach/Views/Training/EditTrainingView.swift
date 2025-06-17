//
//  EditTrainingView.swift.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData

struct EditTrainingView: View {
    
    @ObservedObject var training: Training

    
//    @ObservedObject var training: Training
    var onSave: (() -> Void)? = nil
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date
    @State private var endTime: Date
    @State private var selectedType: TrainingType
    @State private var selectedLocation: TrainingLocation
    @State private var status: TrainingStatus
    @State private var note: String
    @State private var selectedClients: Set<UUID> = []
    @State private var selectedTrainer: Trainer? = nil
    @State private var showDeleteAlert = false
    private let allTrainers = mockTrainers
    
    enum EntryType: String, CaseIterable, Identifiable, Hashable {
        case training = "Тренировка"
        case duty = "Дежурство"
        
        var id: String { rawValue }
    }
    
    // Добавили сохранение исходного статуса
    private let originalStatus: String
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    )
    private var activeClients: FetchedResults<Client>
    
    @Binding var entryType: EntryType

    init(training: Training, entryType: Binding<EntryType>, onSave: (() -> Void)? = nil) {
        self.training = training
        self._entryType = entryType
        self._date = State(initialValue: training.date ?? Date())
        self._endTime = State(initialValue: training.endTime ?? Date())
        self._selectedType = State(initialValue: TrainingType(rawValue: training.type ?? "") ?? .personal)
        self._selectedLocation = State(initialValue: TrainingLocation(rawValue: training.location ?? "") ?? .bigPool)
        self._status = State(initialValue: TrainingStatus(rawValue: training.status ?? "") ?? .planned)
        self._note = State(initialValue: training.note ?? "")
        self.originalStatus = training.status ?? "Запланирована"
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Тип записи")) {
                    Picker("Тип записи", selection: $entryType) {
                        ForEach(EntryType.allCases) { entry in
                            Text(entry.rawValue).tag(entry)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: entryType) { newValue in
                        print("📍 Новый тип записи: \(newValue.rawValue)")
                    }
                }
                if entryType == .training {
                    Section(header: Text("Тренировка")) {
                        DatePicker("Дата и время", selection: $date)
                        DatePicker("Окончание", selection: $endTime)
                        Picker("Тип тренировки", selection: $selectedType) {
                            ForEach(TrainingType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        Picker("Бассейн", selection: $selectedLocation) {
                            ForEach(TrainingLocation.allCases) { location in
                                Text(location.rawValue).tag(location)
                            }
                        }
                        Picker("Статус", selection: $status) {
                            ForEach(TrainingStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                    }
                    
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
                    
                } else {
                    Section(header: Text("Дежурство")) {
                        DatePicker("Дата и время", selection: $date)
                        DatePicker("Окончание", selection: $endTime)
                        Picker("Дежурство за", selection: $selectedTrainer) {
                            ForEach(allTrainers, id: \.self) { trainer in
                                Text(trainer.fullName).tag(trainer)
                            }
                        }
                        Picker("Статус", selection: $status) {
                            ForEach(TrainingStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                    }
                }
                
                Section(header: Text("Заметка")) {
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("Введите заметку...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $note)
                            .frame(height: 100)
                    }
                }
            }
            .id(entryType)
            .navigationTitle("Редактировать")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveChanges()
                        onSave?()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
            
            .onAppear {
                if training.type == "Дежурство" {
                    entryType = .duty
                } else {
                    entryType = .training
                }
                loadSelectedClients()
            }
        }
        .alert("Удалить тренировку?", isPresented: $showDeleteAlert, actions: {
            Button("Удалить", role: .destructive) {
                deleteTraining()
            }
            Button("Отмена", role: .cancel) { }
        }, message: {
            Text("Это действие нельзя отменить. Тренировка будет удалена безвозвратно.")
        })
    }
    @ViewBuilder
    private var trainingFormSection: some View {
        Section(header: Text("Тренировка")) {
            DatePicker("Дата и время", selection: $date)
            DatePicker("Окончание", selection: $endTime)
            Picker("Тип тренировки", selection: $selectedType) {
                ForEach(TrainingType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            Picker("Статус", selection: $status) {
                ForEach(TrainingStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status)
                }
            }
        }

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

    @ViewBuilder
    private var dutyFormSection: some View {
        Section(header: Text("Дежурство")) {
            DatePicker("Дата и время", selection: $date)
            DatePicker("Окончание", selection: $endTime)
            Picker("Дежурство за", selection: $selectedTrainer) {
                ForEach(allTrainers, id: \.self) { trainer in
                    Text(trainer.fullName).tag(trainer)
                }
            }
            Picker("Статус", selection: $status) {
                ForEach(TrainingStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status)
                }
            }
        }
    }
    
    private func deleteTraining() {
        viewContext.delete(training)
        do {
            try viewContext.save()
            onSave?()
            dismiss()
        } catch {
            print("❌ Ошибка при удалении тренировки: \(error.localizedDescription)")
        }
    }

    private func toggleClientSelection(_ client: Client) {
        guard let id = client.id else { return }
        if selectedClients.contains(id) {
            selectedClients.remove(id)
        } else {
            selectedClients.insert(id)
        }
    }

    private func loadSelectedClients() {
        guard let clients = training.clients as? Set<Client> else { return }
        selectedClients = Set(clients.compactMap { $0.id })
    }

    private func saveChanges() {
        guard entryType == .training else {
            training.date = date
            training.endTime = endTime
            training.type = "Дежурство"
            training.location = ""
            training.status = status.rawValue
            if let trainer = selectedTrainer {
                training.note = "[Дежурство за: \(trainer.fullName)] " + note
            } else {
                training.note = note
            }
            training.removeFromClients(training.clients ?? [])

            do {
                try viewContext.save()
                onSave?()
                TrainingUpdateNotifier.shared.notifyUpdate()
            } catch {
                print("Ошибка при сохранении дежурства: \(error.localizedDescription)")
            }
            return
        }
        
        training.date = date
        training.endTime = endTime
        training.type = selectedType.rawValue
        training.location = selectedLocation.rawValue
        training.status = status.rawValue
        training.note = note

        // Обновим список клиентов
        if let existingClients = training.clients as? Set<Client> {
            for client in existingClients {
                if let id = client.id, !selectedClients.contains(id) {
                    training.removeFromClients(client)
                }
            }
        }
        training.removeFromClients(training.clients ?? [])

        for client in activeClients {
            if let id = client.id, selectedClients.contains(id) {
                training.addToClients(client)
            }
        }

        // 👇 Списываем с баланса, если статус изменился на "Проведена" или "Отменена, но списана"
        let statusesToDeduct: [TrainingStatus] = [.completed, .cancelledAndPaid]

        if let old = TrainingStatus(rawValue: originalStatus),
           !statusesToDeduct.contains(old),
           statusesToDeduct.contains(status) {
            for client in activeClients {
                guard let id = client.id else { continue }

                if selectedClients.contains(id),
                   let balances = client.balances as? Set<TrainingBalance>,
                   let balance = balances.first(where: { $0.type == selectedType.rawValue && $0.count > 0 }) {
                    balance.count -= 1
                }
            }
        }
        // 🟢 Возврат баланса, если статус стал НЕсписывающим, а раньше был списывающим
        if let old = TrainingStatus(rawValue: originalStatus),
           statusesToDeduct.contains(old),
           !statusesToDeduct.contains(status) {
            
            for client in activeClients {
                guard let id = client.id else { continue }

                if selectedClients.contains(id),
                   let balances = client.balances as? Set<TrainingBalance>,
                   let balance = balances.first(where: { $0.type == selectedType.rawValue }) {
                    balance.count += 1
                }
            }
        }

        do {
            try viewContext.save()
            onSave?() 
            TrainingUpdateNotifier.shared.notifyUpdate()
        } catch {
            print("Ошибка при сохранении изменений: \(error.localizedDescription)")
        }
    }
}
