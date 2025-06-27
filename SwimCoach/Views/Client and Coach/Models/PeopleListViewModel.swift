//
//  PeopleListViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI
import CoreData

/// ViewModel для управления логикой отображения и взаимодействия с клиентами и тренерами.
class PeopleListViewModel: ObservableObject {
    @Published var selectedTab: TabType = .clients
    @Published var searchText: String = ""
    @Published var isSelectionMode = false
    @Published var selectedClientIDs: Set<UUID> = []
    @Published var selectedCoachIDs: Set<UUID> = []
    @Published var showDeletedPeople = false
    @Published var showDeleteAlert = false
    @Published var showingAddView = false
    @Published var selectedClient: Client?
    @Published var selectedCoach: CoachData?

    // Контекст Core Data
    let context: NSManagedObjectContext

    // Данные из Core Data
    var allClients: FetchedResults<Client>
    var allCoaches: FetchedResults<CoachData>

    init(context: NSManagedObjectContext,
         clients: FetchedResults<Client>,
         coaches: FetchedResults<CoachData>) {
        self.context = context
        self.allClients = clients
        self.allCoaches = coaches
    }

    /// Фильтрация клиентов и тренеров с учётом вкладки, текста поиска и удалённости.
    var filteredItems: [(UUID, String)] {
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

    /// Проверка, выбран ли элемент
    func isSelected(id: UUID) -> Bool {
        selectedTab == .clients ? selectedClientIDs.contains(id) : selectedCoachIDs.contains(id)
    }

    /// Переключение выделения элемента
    func toggleSelection(id: UUID) {
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

    /// Очистка выделений
    func clearSelection() {
        selectedClientIDs.removeAll()
        selectedCoachIDs.removeAll()
    }

    /// Пометить выбранные как удалённые
    func deleteSelected() {
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
            saveChanges()
        }
    }

    /// Восстановить удалённые элементы
    func restoreSelected() {
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
            saveChanges()
        }
    }

    /// Полностью удалить элементы
    func deletePermanently() {
        withAnimation {
            if selectedTab == .clients {
                for client in allClients where selectedClientIDs.contains(client.id ?? UUID()) {
                    context.delete(client)
                }
            } else {
                for coach in allCoaches where selectedCoachIDs.contains(coach.id ?? UUID()) {
                    context.delete(coach)
                }
            }
            saveChanges()
        }
    }

    /// Сохранить изменения в Core Data
    private func saveChanges() {
        do {
            try context.save()
            clearSelection()
            isSelectionMode = false
        } catch {
            print("❌ Ошибка сохранения: \(error.localizedDescription)")
        }
    }

    /// Текст, если список пуст
    var emptyLabel: String {
        switch selectedTab {
        case .clients: return "Нет удалённых клиентов"
        case .coaches: return "Нет удалённых тренеров"
        }
    }
}
