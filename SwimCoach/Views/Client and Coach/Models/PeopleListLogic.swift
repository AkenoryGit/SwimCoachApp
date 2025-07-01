//
//  PeopleListLogic.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import Foundation
import SwiftUI

extension PeopleListView {

    // MARK: - Заголовок
    var currentTitle: String {
        selectedTab == .clients
        ? (showDeletedPeople ? "Удалённые клиенты" : "Клиенты")
        : (showDeletedPeople ? "Удалённые тренера" : "Тренера")
    }

    // MARK: - Фильтрация
    var filteredClients: [Client] {
        allClients
            .filter { showDeletedPeople ? $0.isDeletedClient : !$0.isDeletedClient }
            .filter { searchText.isEmpty || ($0.fullName ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    var filteredCoaches: [CoachData] {
        allCoaches
            .filter { showDeletedPeople ? $0.isMarkedDeleted : !$0.isMarkedDeleted }
            .filter { searchText.isEmpty || ($0.fullName ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Выбор
    func isSelected(id: UUID) -> Bool {
        selectedTab == .clients ? selectedClientIDs.contains(id) : selectedCoachIDs.contains(id)
    }

    func toggleSelection(id: UUID) {
        if selectedTab == .clients {
            selectedClientIDs.formSymmetricDifference([id])
        } else {
            selectedCoachIDs.formSymmetricDifference([id])
        }
    }

    func clearSelection() {
        selectedClientIDs.removeAll()
        selectedCoachIDs.removeAll()
    }

    // MARK: - Удаление / Восстановление / Полное удаление
    func deleteSelected() {
        withAnimation {
            if selectedTab == .clients {
                allClients.filter { selectedClientIDs.contains($0.id ?? UUID()) }.forEach { $0.isDeletedClient = true }
            } else {
                allCoaches.filter { selectedCoachIDs.contains($0.id ?? UUID()) }.forEach { $0.isMarkedDeleted = true }
            }
            try? viewContext.save()
            clearSelection()
            isSelectionMode = false
        }
    }

    func restoreSelected() {
        withAnimation {
            if selectedTab == .clients {
                allClients.filter { selectedClientIDs.contains($0.id ?? UUID()) }.forEach { $0.isDeletedClient = false }
            } else {
                allCoaches.filter { selectedCoachIDs.contains($0.id ?? UUID()) }.forEach { $0.isMarkedDeleted = false }
            }
            try? viewContext.save()
            clearSelection()
            isSelectionMode = false
        }
    }

    func deletePermanently() {
        withAnimation {
            if selectedTab == .clients {
                allClients.filter { selectedClientIDs.contains($0.id ?? UUID()) }.forEach(viewContext.delete)
            } else {
                allCoaches.filter { selectedCoachIDs.contains($0.id ?? UUID()) }.forEach(viewContext.delete)
            }
            try? viewContext.save()
            clearSelection()
            isSelectionMode = false
        }
    }
}
