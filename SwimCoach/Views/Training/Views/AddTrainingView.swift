//
//  AddTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

// MARK: - Экран добавления новой тренировки или дежурства
struct AddTrainingView: View {

    // MARK: - Среда окружения
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModel
    @ObservedObject var viewModel: AddTrainingViewModel

    @State private var showTimeErrorAlert = false
    @State private var timeErrorMessage = ""

    // MARK: - Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    ) private var activeClients: FetchedResults<Client>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CoachData.fullName, ascending: true)],
        predicate: NSPredicate(format: "isMarkedDeleted == NO"),
        animation: .default
    ) private var activeTrainers: FetchedResults<CoachData>

    // MARK: - UI
    var body: some View {
            KeyboardDismissWrapper {
                Form {
                    // MARK: - Тип записи
                    Section(header: Text("Тип записи")) {
                        Picker("Тип", selection: $viewModel.entryType) {
                            ForEach(EntryType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // MARK: - Тренер (для дежурства)
                    if viewModel.entryType == .duty {
                        Section(header: Text("Дежурный тренер")) {
                            TextField("Поиск тренера", text: $viewModel.trainerSearchText)
                                .textFieldStyle(.roundedBorder)
                            
                            let filtered = viewModel.filteredTrainers(from: activeTrainers)
                            let limited = viewModel.showAllTrainers ? filtered : Array(filtered.prefix(3))
                            
                            ForEach(limited, id: \.objectID) { trainer in
                                Button {
                                    viewModel.selectedTrainer = trainer
                                } label: {
                                    HStack {
                                        Text(trainer.fullName ?? "Без имени")
                                        Spacer()
                                        if viewModel.selectedTrainer?.objectID == trainer.objectID {
                                            Image(systemName: "checkmark").foregroundColor(.blue)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if filtered.count > 3 {
                                Button(viewModel.showAllTrainers ? "Свернуть" : "Показать всех") {
                                    withAnimation {
                                        viewModel.showAllTrainers.toggle()
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // MARK: - Дата и параметры
                    Section(header: Text("Дата и параметры")) {
                        DatePicker("Дата и время", selection: $viewModel.date)
                            .onChange(of: viewModel.date) {
                                viewModel.endTime = viewModel.calculateEndTime(
                                    for: viewModel.selectedType.rawValue,
                                    startDate: viewModel.date
                                )
                            }
                        
                        DatePicker("Окончание", selection: $viewModel.endTime)
                        
                        if viewModel.entryType == .training {
                            Picker("Тип тренировки", selection: $viewModel.selectedType) {
                                ForEach(TrainingType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .onChange(of: viewModel.selectedType) {
                                viewModel.endTime = viewModel.calculateEndTime(
                                    for: viewModel.selectedType.rawValue,
                                    startDate: viewModel.date
                                )
                            }
                            
                            Picker("Локация", selection: $viewModel.selectedLocation) {
                                ForEach(TrainingLocation.allCases) { location in
                                    Text(location.rawValue).tag(location)
                                }
                            }
                        }
                        
                        Picker("Статус", selection: $viewModel.status) {
                            Text("Запланирована").tag("Запланирована")
                            Text("Проведена").tag("Проведена")
                        }
                    }
                    
                    // MARK: - Клиенты
                    if viewModel.entryType == .training {
                        Section(header: Text("Клиенты")) {
                            TextField("Поиск клиента", text: $viewModel.clientSearchText)
                                .textFieldStyle(.roundedBorder)
                            
                            let filtered = viewModel.filteredClients(from: activeClients)
                            let limitedClients = viewModel.showAllClients ? filtered : Array(filtered.prefix(4))
                            
                            ForEach(limitedClients) { client in
                                if let clientID = client.id {
                                    Button {
                                        viewModel.toggleClientSelection(clientID)
                                    } label: {
                                        HStack {
                                            Text(client.fullName ?? "Без имени")
                                            Spacer()
                                            if viewModel.selectedClients.contains(clientID) {
                                                Image(systemName: "checkmark").foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            if filtered.count > 4 {
                                Button(viewModel.showAllClients ? "Свернуть" : "Показать всех") {
                                    withAnimation {
                                        viewModel.showAllClients.toggle()
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // MARK: - Заметка
                    Section(header: Text("Заметка")) {
                        TextEditor(text: $viewModel.note)
                            .frame(height: 100)
                    }
                }
            }
        
        .navigationTitle("Новая тренировка")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    validateAndSave()
                }
                .disabled(viewModel.entryType == .training && viewModel.selectedClients.isEmpty)
            }
        }
        .alert("Ошибка", isPresented: $viewModel.showTimeErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.timeErrorMessage)
        }
    }

    // MARK: - Валидация
    private func validateAndSave() {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: viewModel.date)
        let endHour = calendar.component(.hour, from: viewModel.endTime)

        if startHour < 6 || endHour < 6 {
            timeErrorMessage = "Время должно быть между 06:00 и 23:00"
            showTimeErrorAlert = true
            return
        }

        if viewModel.date >= viewModel.endTime {
            timeErrorMessage = "Время начала не может быть позже или равно времени окончания"
            showTimeErrorAlert = true
            return
        }

        if viewModel.endTime.timeIntervalSince(viewModel.date) < 60 * 20 {
            timeErrorMessage = "Минимальная длительность — 20 минут"
            showTimeErrorAlert = true
            return
        }

        viewModel.saveTraining(
            context: viewContext,
            activeClients: activeClients,
            activeTrainers: activeTrainers
        ) {
            dismiss()
        }
    }
}
