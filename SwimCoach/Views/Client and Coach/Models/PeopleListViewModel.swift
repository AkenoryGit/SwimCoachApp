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
    @Published var showingProtectedCoachAlert = false
    @Published var showingProtectedClientAlert = false

    // Контекст Core Data
    let context: NSManagedObjectContext

    // Данные из Core Data
    var allClients: [Client]
    var allCoaches: [CoachData]
    
    init(context: NSManagedObjectContext,
         clients: [Client],
         coaches: [CoachData]) {
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
                .compactMap { item in
                    if let id = item.id {
                        return (id, item.fullName ?? "Без имени")
                    }
                    return nil
                }
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
    func deleteSelectedOrPermanently() {
        print("SelectedTab: \(selectedTab)")
        print("Selected clients: \(selectedClientIDs)")
        print("Selected coaches: \(selectedCoachIDs)")
        
        withAnimation {
            if selectedTab == .clients {
                let clientsToDelete = allClients.filter { selectedClientIDs.contains($0.id ?? UUID()) }

                // Проверка: есть ли клиенты с тренировками
                if clientsToDelete.contains(where: { ($0.training as? Set<Training>)?.isEmpty == false }) {
                    DispatchQueue.main.async {
                        // Показываем алерт о том, что нельзя удалить
                        self.showingProtectedClientAlert = true
                    }
                    return
                }

                for client in clientsToDelete {
                    if client.isDeletedClient {
                        context.delete(client)
                    } else {
                        client.isDeletedClient = true
                    }
                }
            } else {
                // Проверка: есть ли хотя бы один тренер с дежурствами
                let coachesToDelete = allCoaches.filter { selectedCoachIDs.contains($0.id ?? UUID()) }
                
                for coach in coachesToDelete {
                    context.refresh(coach, mergeChanges: true)
                }

                if coachesToDelete.contains(where: {
                    if let duties = $0.duties {
                        print("Проверяем тренера \($0.fullName ?? "Без имени") — количество дежурств: \(duties.count)")
                        return duties.count > 0
                    } else {
                        print("У тренера \($0.fullName ?? "Без имени") нет duties")
                        return false
                    }
                }) {
                    DispatchQueue.main.async {
                        self.showingProtectedCoachAlert = true
                    }
                    return
                }

                // Если всё чисто — продолжаем
                for coach in coachesToDelete {
                    if coach.isMarkedDeleted {
                        context.delete(coach)
                    } else {
                        coach.isMarkedDeleted = true
                    }
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
