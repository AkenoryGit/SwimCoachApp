//
//  AllTrainingsView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData

// MARK: - Экран всех тренировок и дежурств

struct AllTrainingsView: View {
    
    @State private var selectedEntry: PositionedEntry?

    // MARK: - Core Data
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Training.date, ascending: false)],
        animation: .default
    ) private var allTrainings: FetchedResults<Training>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Duty.date, ascending: false)],
        animation: .default
    ) private var allDuties: FetchedResults<Duty>

    // MARK: - UI состояния
    @State private var selectedType: EntryType = .training
    @State private var searchText = ""
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<UUID> = []
    @State private var showDeleteAlert = false
    @State private var showFilterOptions = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Прозрачный фон для скрытия клавиатуры
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isSearchFocused = false
                        hideKeyboard()
                    }

                VStack(spacing: 0) {

                    // MARK: - Переключатель "Тренировки" / "Дежурства"
                    Picker("Тип", selection: $selectedType) {
                        Text("Тренировки").tag(EntryType.training)
                        Text("Дежурства").tag(EntryType.duty)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // MARK: - Поиск и фильтр
                    HStack {
                        TextField("Поиск по клиентам", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading)
                            .focused($isSearchFocused)

                        Button {
                            showFilterOptions = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .imageScale(.large)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 8)

                    // MARK: - Список записей или заглушка
                    if filteredEntries.isEmpty {
                        Spacer()
                        Text(emptyMessage)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredEntries) { item in
                                HStack {
                                    if isSelectionMode {
                                        Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                toggleSelection(for: item)
                                            }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formattedDate(item.date))
                                            .font(.headline)
                                        Text(item.title)
                                            .font(.subheadline)

                                        if !item.clientNames.isEmpty {
                                            Text("Клиенты: \(item.clientNames)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)

                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if isSelectionMode {
                                        toggleSelection(for: item)
                                    } else {
                                        selectedEntry = item.toPositionedEntry()
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                isSearchFocused = false
                                hideKeyboard()
                            }
                        )
                    }

                    // MARK: - Нижняя панель при выборе
                    if isSelectionMode {
                        HStack {
                            Button("Удалить", role: .destructive) {
                                showDeleteAlert = true
                            }
                            .padding()

                            Spacer()

                            Button("Отмена") {
                                cancelSelection()
                            }
                            .padding()
                        }
                        .background(Color(.systemGroupedBackground))
                    }
                }
            }
            .navigationTitle("Все \(selectedType == .training ? "тренировки" : "дежурства")")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSelectionMode ? "Готово" : "Выбрать") {
                        isSelectionMode.toggle()
                        if !isSelectionMode {
                            selectedItems.removeAll()
                        }
                    }
                }
            }
            .alert("Удалить выбранные записи?", isPresented: $showDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    deleteSelectedItems()
                }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text("Это действие нельзя отменить.")
            }
            .onAppear {
                assignIDsToLegacyDuties()
            }
        }
        .sheet(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry) {
                selectedEntry = nil
            }
        }
    }

    // MARK: - Отфильтрованные записи
    private var filteredEntries: [AnyIdentifiableEntry] {
        let base: [AnyIdentifiableEntry] = {
            switch selectedType {
            case .training:
                return allTrainings.map { .training($0) }
            case .duty:
                return allDuties.map { .duty($0) }
            }
        }()

        return base.filter {
            searchText.isEmpty || $0.clientNames.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Удаление выбранных записей
    private func deleteSelectedItems() {
        withAnimation {
            for id in selectedItems {
                switch selectedType {
                case .training:
                    if let item = allTrainings.first(where: { $0.id == id }) {
                        viewContext.delete(item)
                    }
                case .duty:
                    if let item = allDuties.first(where: { $0.id == id }) {
                        viewContext.delete(item)
                    }
                }
            }

            do {
                try viewContext.save()
                selectedItems.removeAll()
                isSelectionMode = false
                TrainingUpdateNotifier.shared.notifyUpdate()
            } catch {
                print("❌ Ошибка удаления: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Переключение выбранности записи
    private func toggleSelection(for item: AnyIdentifiableEntry) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }

    // MARK: - Отмена режима выбора
    private func cancelSelection() {
        selectedItems.removeAll()
        isSelectionMode = false
    }

    // MARK: - Пустое сообщение
    private var emptyMessage: String {
        selectedType == .training ? "Нет записей тренировок" : "Нет записей дежурств"
    }

    // MARK: - Форматирование даты
    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "Без даты" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    // MARK: - Обновление старых дежурств (без id)
    private func assignIDsToLegacyDuties() {
        let request = NSFetchRequest<Duty>(entityName: "Duty")
        do {
            let allDuties = try viewContext.fetch(request)
            for duty in allDuties where duty.id == nil {
                duty.id = UUID()
            }
            try viewContext.save()
            print("🔁 Старым дежурствам назначены id")
        } catch {
            print("❌ Ошибка при обновлении старых дежурств: \(error)")
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

