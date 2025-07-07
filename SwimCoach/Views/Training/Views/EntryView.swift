//
//  EntryView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 30.06.2025.
//

import SwiftUI
import CoreData

struct EntryView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: EntryViewModel

    @State private var showRecurrenceDeleteDialog = false
    @State private var showRecurrenceEditDialog = false

    var activeClients: FetchedResults<Client>
    var activeTrainers: FetchedResults<CoachData>
    var onSave: (() -> Void)? = nil

    var body: some View {
        KeyboardDismissWrapper {
            Form {
                if viewModel.mode == .create {
                    Section(header: Text("Тип записи")) {
                        Picker("Категория", selection: $viewModel.category) {
                            Text("Тренировка").tag(EntryCategory.training)
                            Text("Дежурство").tag(EntryCategory.duty)
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section(header: Text("Дата и время")) {
                    DatePicker("Начало", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Окончание", selection: $viewModel.endTime, displayedComponents: [.date, .hourAndMinute])
                    Picker("Длительность", selection: $viewModel.selectedDuration) {
                        ForEach(viewModel.possibleDurations, id: \.self) { duration in
                            Text("\(duration)").tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                RepeatSectionView(repeatFrequency: $viewModel.repeatFrequency)

                if viewModel.category == .training {
                    TrainingTypeSectionView(
                        selectedType: $viewModel.selectedType,
                        selectedLocation: $viewModel.selectedLocation,
                        status: $viewModel.status,
                        onTypeOrLocationChanged: viewModel.onTypeOrLocationChanged
                    )

                    ClientsSelectionSectionView(
                        clientSearchText: $viewModel.clientSearchText,
                        filteredClients: viewModel.filteredClients(from: activeClients),
                        selectedClients: $viewModel.selectedClients,
                        showAllClients: $viewModel.showAllClients,
                        toggleClientSelection: viewModel.toggleClientSelection
                    )
                }

                if viewModel.category == .duty {
                    TrainerSelectionSectionView(
                        trainerSearchText: $viewModel.trainerSearchText,
                        filteredTrainers: viewModel.filteredTrainers(from: activeTrainers),
                        selectedTrainer: $viewModel.selectedTrainer,
                        showAllTrainers: $viewModel.showAllTrainers
                    )

                    Section(header: Text("Статус")) {
                        Picker("Статус", selection: $viewModel.status) {
                            Text("Запланировано").tag("Запланирована")
                            Text("Проведено").tag("Проведена")
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section(header: Text("Заметка")) {
                    TextEditor(text: $viewModel.note)
                        .frame(minHeight: 100)
                }
            }
        }
        .navigationTitle(viewModel.mode == .create ? "Новая запись" : "Редактирование")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    if viewModel.mode == .edit && viewModel.repeatFrequency != nil {
                        showRecurrenceEditDialog = true
                    } else {
                        Task {
                            await saveEntry()
                        }
                    }
                }
                .disabled(
                    viewModel.category == .training &&
                    ![.group, .miniGroup, .split].contains(viewModel.selectedType) &&
                    viewModel.selectedClients.isEmpty
                )
            }
            ToolbarItem(placement: .bottomBar) {
                if viewModel.mode == .edit {
                    Button("Удалить", role: .destructive) {
                        if viewModel.repeatFrequency != nil {
                            showRecurrenceDeleteDialog = true
                        } else {
                            viewModel.delete(context: viewContext) {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .alert("Ошибка", isPresented: $viewModel.showTimeErrorAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(viewModel.timeErrorMessage)
        }
        .confirmationDialog("Эта запись повторяется. Что вы хотите удалить?",
                            isPresented: $showRecurrenceDeleteDialog) {
            Button("Только эту") {
                viewModel.recurrenceEditMode = .thisOnly
                viewModel.delete(context: viewContext) {
                    dismiss()
                }
            }

            Button("Эту и все следующие") {
                viewModel.recurrenceEditMode = .thisAndFollowing
                viewModel.delete(context: viewContext) {
                    dismiss()
                }
            }

            Button("Отмена", role: .cancel) {}
        }
        .confirmationDialog("Эта запись повторяется. Что вы хотите изменить?",
                            isPresented: $showRecurrenceEditDialog) {
            Button("Только эту") {
                viewModel.recurrenceEditMode = .thisOnly
                Task { await saveEntry() }
            }

            Button("Эту и все следующие") {
                viewModel.recurrenceEditMode = .thisAndFollowing
                Task { await saveEntry() }
            }

            Button("Отмена", role: .cancel) {}
        }
    }

    @MainActor
    private func saveEntry() async {
        viewModel.save(context: viewContext,
                       activeClients: activeClients,
                       activeTrainers: activeTrainers) {
            onSave?()
            dismiss()
        }
    }
}

private struct RepeatSectionView: View {
    @Binding var repeatFrequency: RepeatFrequency?

    var body: some View {
        Section(header: Text("Повтор")) {
            Picker("Частота", selection: Binding(get: {
                repeatFrequency ?? .noneSelected
            }, set: { newValue in
                repeatFrequency = newValue == .noneSelected ? nil : newValue
            })) {
                ForEach(RepeatFrequency.allCasesWithNone, id: \.self) { frequency in
                    Text(frequency.title).tag(frequency)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

private struct TrainingTypeSectionView: View {
    @Binding var selectedType: TrainingType
    @Binding var selectedLocation: TrainingLocation
    @Binding var status: String
    var onTypeOrLocationChanged: (TrainingType, TrainingLocation) -> Void

    var body: some View {
        Section(header: Text("Тип тренировки")) {
            Picker("Тип", selection: Binding(
                get: { selectedType },
                set: { newType in
                    onTypeOrLocationChanged(newType, selectedLocation)
                }
            )) {
                ForEach(TrainingType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)

            Picker("Локация", selection: Binding(
                get: { selectedLocation },
                set: { newLocation in
                    onTypeOrLocationChanged(selectedType, newLocation)
                }
            )) {
                ForEach(TrainingLocation.allCases) { location in
                    Text(location.rawValue).tag(location)
                }
            }
            .pickerStyle(.menu)

            Picker("Статус", selection: $status) {
                Text("Запланирована").tag("Запланирована")
                Text("Проведена").tag("Проведена")
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct ClientsSelectionSectionView: View {
    @Binding var clientSearchText: String
    var filteredClients: [Client]
    @Binding var selectedClients: Set<UUID>
    @Binding var showAllClients: Bool
    var toggleClientSelection: (UUID) -> Void

    var body: some View {
        Section(header: Text("Клиенты")) {
            TextField("Поиск клиента", text: $clientSearchText)
                .textFieldStyle(.roundedBorder)

            let clientsToShow = showAllClients ? filteredClients : Array(filteredClients.prefix(4))

            ForEach(clientsToShow) { client in
                if let clientID = client.id {
                    Button(action: {
                        toggleClientSelection(clientID)
                    }) {
                        HStack {
                            Text(client.fullName ?? "Без имени")
                            Spacer()
                            if selectedClients.contains(clientID) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            if filteredClients.count > 4 {
                Button(showAllClients ? "Свернуть" : "Показать всех") {
                    withAnimation {
                        showAllClients.toggle()
                    }
                }
                .foregroundColor(.blue)
            }
        }
    }
}

private struct TrainerSelectionSectionView: View {
    @Binding var trainerSearchText: String
    var filteredTrainers: [CoachData]
    @Binding var selectedTrainer: CoachData?
    @Binding var showAllTrainers: Bool

    var body: some View {
        Section(header: Text("Тренер")) {
            TextField("Поиск тренера", text: $trainerSearchText)
                .textFieldStyle(.roundedBorder)

            let trainersToShow = showAllTrainers ? filteredTrainers : Array(filteredTrainers.prefix(3))

            ForEach(trainersToShow, id: \.objectID) { trainer in
                Button(action: {
                    selectedTrainer = trainer
                }) {
                    HStack {
                        Text(trainer.fullName ?? "Без имени")
                        Spacer()
                        if selectedTrainer?.objectID == trainer.objectID {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            if filteredTrainers.count > 3 {
                Button(showAllTrainers ? "Свернуть" : "Показать всех") {
                    withAnimation {
                        showAllTrainers.toggle()
                    }
                }
                .foregroundColor(.blue)
            }
        }
    }
}
