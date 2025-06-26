//
//  PeopleListView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 25.06.2025.
//

import SwiftUI
import CoreData

// MARK: - Экран списка клиентов и тренеров

struct PeopleListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Вкладка: клиенты или тренеры
    enum TabType: String, CaseIterable {
        case clients = "Клиенты"
        case coaches = "Тренера"
    }

    @State private var selectedTab: TabType = .clients
    @State private var showingAddView = false
    @State private var selectedClient: Client?
    @State private var selectedCoach: CoachData?

    // MARK: - Запросы к Core Data
    @FetchRequest(
        entity: Client.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)]
    ) private var allClients: FetchedResults<Client>

    @FetchRequest(
        entity: CoachData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CoachData.fullName, ascending: true)]
    ) private var allCoaches: FetchedResults<CoachData>

    // MARK: - Состояния UI
    @State private var searchText = ""
    @State private var isSelectionMode = false
    @State private var selectedClientIDs: Set<UUID> = []
    @State private var selectedCoachIDs: Set<UUID> = []
    @State private var showDeleteAlert = false
    @State private var showDeletedPeople = false

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // MARK: - Переключатель "Клиенты / Тренера"
                    Picker("Тип", selection: $selectedTab) {
                        ForEach(TabType.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // MARK: - Поисковая строка и фильтр
                    HStack {
                        TextField("Поиск по имени", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.leading)
                            .focused($isSearchFocused)

                        Button {
                            // Здесь может быть экран фильтра
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .imageScale(.large)
                                .padding(.trailing)
                        }
                    }

                    // MARK: - Список или сообщение об отсутствии
                    if filteredItems.isEmpty {
                        VStack {
                            Spacer()
                            Text(selectedTab == .clients ? "Нет удалённых клиентов" : "Нет удалённых тренеров")
                                .foregroundColor(.secondary)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                    } else {
                        List {
                            ForEach(filteredItems, id: \.0) { (id, name) in
                                HStack {
                                    if isSelectionMode {
                                        Image(systemName: isSelected(id: id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.blue)
                                    }

                                    Text(name)
                                        .padding(.vertical, 8)

                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .background(showDeletedPeople ? Color.red.opacity(0.1) : Color.clear)
                                .onTapGesture {
                                    if isSelectionMode {
                                        toggleSelection(id: id)
                                    } else {
                                        if selectedTab == .clients {
                                            if let client = allClients.first(where: { $0.id == id }) {
                                                selectedClient = client
                                            }
                                        } else {
                                            if let coach = allCoaches.first(where: { $0.id == id }) {
                                                selectedCoach = coach
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }

                    // MARK: - Кнопка "Показать удалённые"
                    Button(showDeletedPeople ? "Скрыть удалённые" : "Показать удалённые") {
                        showDeletedPeople.toggle()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)

                    // MARK: - Панель управления выбором
                    if isSelectionMode {
                        HStack {
                            if showDeletedPeople {
                                Button("Восстановить") {
                                    restoreSelected()
                                }
                                .foregroundColor(.blue)
                                .padding()

                                Button("Удалить навсегда") {
                                    showDeleteAlert = true
                                }
                                .foregroundColor(.red)
                                .padding()
                            } else {
                                Button("Удалить") {
                                    showDeleteAlert = true
                                }
                                .foregroundColor(.red)
                                .padding()
                            }

                            Spacer()

                            Button("Отмена") {
                                clearSelection()
                            }
                            .padding()
                        }
                        .background(Color(.systemGroupedBackground))
                    }
                }
                .navigationTitle(
                    selectedTab == .clients
                    ? (showDeletedPeople ? "Удалённые клиенты" : "Клиенты")
                    : (showDeletedPeople ? "Удалённые тренера" : "Тренера")
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isSelectionMode ? "Готово" : "Выбрать") {
                            isSelectionMode.toggle()
                            if !isSelectionMode {
                                clearSelection()
                            }
                        }
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingAddView = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddView) {
                    if selectedTab == .clients {
                        AddClientView()
                    } else {
                        AddCoachView()
                    }
                }
                .alert(showDeletedPeople ? "Удалить навсегда?" : "Удалить выбранные записи?", isPresented: $showDeleteAlert) {
                    Button("Удалить", role: .destructive) {
                        showDeletedPeople ? deletePermanently() : deleteSelected()
                    }
                    Button("Отмена", role: .cancel) {}
                } message: {
                    Text("Это действие нельзя отменить.")
                }
                .sheet(item: $selectedClient) { client in
                    ClientDetailView(client: client)
                }
                .sheet(item: $selectedCoach) { coach in
                    CoachDetailView(coach: coach)
                }
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    isSearchFocused = false
                }
            )
        }
    }

    // MARK: - Фильтрация
    private var filteredItems: [(UUID, String)] {
        switch selectedTab {
        case .clients:
            return allClients
                .filter { showDeletedPeople ? $0.isDeletedClient : !$0.isDeletedClient }
                .filter { searchText.isEmpty || ($0.fullName ?? "").localizedCaseInsensitiveContains(searchText) }
                .compactMap { ($0.id, $0.fullName ?? "Без имени") }
                .compactMap { id, name in id.map { ($0, name) } }

        case .coaches:
            return allCoaches
                .filter { showDeletedPeople ? $0.isMarkedDeleted : !$0.isMarkedDeleted }
                .filter { searchText.isEmpty || ($0.fullName ?? "").localizedCaseInsensitiveContains(searchText) }
                .compactMap { ($0.id, $0.fullName ?? "Без имени") }
                .compactMap { id, name in id.map { ($0, name) } }
        }
    }

    // MARK: - Выбор
    private func isSelected(id: UUID) -> Bool {
        selectedTab == .clients ? selectedClientIDs.contains(id) : selectedCoachIDs.contains(id)
    }

    private func toggleSelection(id: UUID) {
        if selectedTab == .clients {
            if selectedClientIDs.contains(id) {
                selectedClientIDs.remove(id)
            } else {
                selectedClientIDs.insert(id)
            }
        } else {
            if selectedCoachIDs.contains(id) {
                selectedCoachIDs.remove(id)
            } else {
                selectedCoachIDs.insert(id)
            }
        }
    }

    private func clearSelection() {
        selectedClientIDs.removeAll()
        selectedCoachIDs.removeAll()
    }

    // MARK: - Удаление в корзину
    private func deleteSelected() {
        withAnimation {
            if selectedTab == .clients {
                for client in allClients where selectedClientIDs.contains(client.id ?? UUID()) {
                    client.isDeletedClient = true
                }
            } else {
                for coach in allCoaches where selectedCoachIDs.contains(coach.id ?? UUID()) {
                    coach.isMarkedDeleted = true
                }
            }

            do {
                try viewContext.save()
                clearSelection()
                isSelectionMode = false
            } catch {
                print("❌ Ошибка при удалении: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Восстановление
    private func restoreSelected() {
        withAnimation {
            if selectedTab == .clients {
                for client in allClients where selectedClientIDs.contains(client.id ?? UUID()) {
                    client.isDeletedClient = false
                }
            } else {
                for coach in allCoaches where selectedCoachIDs.contains(coach.id ?? UUID()) {
                    coach.isMarkedDeleted = false
                }
            }

            do {
                try viewContext.save()
                clearSelection()
                isSelectionMode = false
            } catch {
                print("❌ Ошибка при восстановлении: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Полное удаление
    private func deletePermanently() {
        withAnimation {
            if selectedTab == .clients {
                for client in allClients where selectedClientIDs.contains(client.id ?? UUID()) {
                    viewContext.delete(client)
                }
            } else {
                for coach in allCoaches where selectedCoachIDs.contains(coach.id ?? UUID()) {
                    viewContext.delete(coach)
                }
            }

            do {
                try viewContext.save()
                clearSelection()
                isSelectionMode = false
            } catch {
                print("❌ Ошибка при полном удалении: \(error.localizedDescription)")
            }
        }
    }
}
    
