//
//  EditTrainingView.swift.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData

// MARK: - Экран редактирования тренировки или дежурства

struct EditTrainingView: View {

    // MARK: - Окружение и зависимости

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: EditTrainingViewModel
    var onSave: (() -> Void)? = nil

    // MARK: - Получение активных клиентов из базы

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    )
    private var activeClients: FetchedResults<Client>

    // MARK: - Основной UI

    var body: some View {
        NavigationStack {
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

                // MARK: - Форма тренировки или дежурства
                if viewModel.entryType == .training {
                    trainingForm
                    clientSelectionSection
                } else {
                    dutyForm
                }

                // MARK: - Заметка
                Section(header: Text("Заметка")) {
                    ZStack(alignment: .topLeading) {
                        if viewModel.note.isEmpty {
                            Text("Введите заметку...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $viewModel.note)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("Редактировать")
            .toolbar {
                // MARK: - Кнопки навигации
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        viewModel.saveChanges(context: viewContext, clients: activeClients, onSave: onSave)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        viewModel.showDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
            .alert("Удалить тренировку?", isPresented: $viewModel.showDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    viewModel.deleteTraining(context: viewContext) {
                        onSave?()
                        dismiss()
                    }
                }
                Button("Отмена", role: .cancel) { }
            }
            .onAppear {
                viewModel.loadInitialState(activeClients: activeClients)
            }
        }
    }

    // MARK: - Подформа для тренировки

    private var trainingForm: some View {
        Section(header: Text("Тренировка")) {
            DatePicker("Дата и время", selection: $viewModel.date)
            DatePicker("Окончание", selection: $viewModel.endTime)

            Picker("Тип тренировки", selection: $viewModel.selectedType) {
                ForEach(TrainingType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }

            Picker("Бассейн", selection: $viewModel.selectedLocation) {
                ForEach(TrainingLocation.allCases) { location in
                    Text(location.rawValue).tag(location)
                }
            }

            Picker("Статус", selection: $viewModel.status) {
                ForEach(TrainingStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status)
                }
            }
        }
    }

    // MARK: - Подформа для дежурства

    private var dutyForm: some View {
        Section(header: Text("Дежурство")) {
            DatePicker("Дата и время", selection: $viewModel.date)
            DatePicker("Окончание", selection: $viewModel.endTime)

            Picker("Дежурство за", selection: $viewModel.selectedTrainer) {
                ForEach(viewModel.allTrainers, id: \.self) { trainer in
                    Text(trainer.fullName).tag(Optional(trainer))
                }
            }

            Picker("Статус", selection: $viewModel.status) {
                ForEach(TrainingStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status)
                }
            }
        }
    }

    // MARK: - Секция выбора клиентов

    private var clientSelectionSection: some View {
        Section(header: Text("Клиенты")) {
            ForEach(activeClients) { client in
                MultipleSelectionRow(
                    title: client.fullName ?? "Без имени",
                    isSelected: viewModel.selectedClients.contains(client.id ?? UUID())
                ) {
                    viewModel.toggleClientSelection(client)
                }
            }
        }
    }
}

