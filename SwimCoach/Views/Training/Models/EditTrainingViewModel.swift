//
//  EditTrainingViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - ViewModel для редактирования существующей тренировки

/// ViewModel, отвечающий за редактирование данных существующей тренировки.
/// Используется экраном `EditTrainingView` для отображения и управления состоянием UI.
final class EditTrainingViewModel: ObservableObject, Identifiable {

    // MARK: - Идентификатор модели

    /// Уникальный идентификатор, соответствующий ID редактируемой тренировки
    var id: UUID { training.id ?? UUID() }

    // MARK: - Опубликованные свойства, связанные с UI

    @Published var date: Date
    @Published var endTime: Date
    @Published var selectedType: TrainingType
    @Published var selectedLocation: TrainingLocation
    @Published var status: TrainingStatus
    @Published var note: String
    @Published var selectedClients: Set<UUID> = []
    @Published var showAllClients: Bool = false
    @Published var clientSearchText: String = ""
    @Published var showDeleteAlert = false

    // MARK: - Приватные свойства

    /// Исходный статус, необходим для корректного пересчёта баланса занятий
    private let originalStatus: String

    /// Сохраняемая ссылка на объект тренировки из Core Data
    private let training: Training

    // MARK: - Инициализация

    init(training: Training) {
        self.training = training
        self.date = training.date ?? Date()
        self.endTime = training.endTime ?? Date()
        self.selectedType = TrainingType(rawValue: training.type ?? "") ?? .personal
        self.selectedLocation = TrainingLocation(rawValue: training.location ?? "") ?? .bigPool
        self.status = TrainingStatus(rawValue: training.status ?? "") ?? .planned
        self.note = training.note ?? ""
        self.originalStatus = training.status ?? "Запланирована"

        if let clients = training.clients as? Set<Client> {
            self.selectedClients = Set(clients.compactMap { $0.id })
        }
    }

    // MARK: - Работа с клиентами

    func filteredClients(from allClients: FetchedResults<Client>) -> [Client] {
        if clientSearchText.isEmpty {
            return Array(allClients)
        } else {
            return allClients.filter {
                $0.fullName?.localizedCaseInsensitiveContains(clientSearchText) ?? false
            }
        }
    }

    func toggleClientSelection(_ id: UUID) {
        if selectedClients.contains(id) {
            selectedClients.remove(id)
        } else {
            selectedClients.insert(id)
        }
    }

    // MARK: - Сохранение изменений

    func saveChanges(context: NSManagedObjectContext,
                     clients: FetchedResults<Client>,
                     onSave: (() -> Void)?) {

        training.type = selectedType.rawValue
        training.location = selectedLocation.rawValue
        training.status = status.rawValue
        training.date = date
        training.endTime = endTime
        training.note = note

        training.removeFromClients(training.clients ?? [])
        for client in clients {
            guard let id = client.id else { continue }
            if selectedClients.contains(id) {
                training.addToClients(client)
            }
        }

        updateBalancesIfNeeded(clients: clients)

        do {
            try context.save()
            onSave?()
            TrainingUpdateNotifier.shared.notifyUpdate()
        } catch {
            print("❌ Ошибка при сохранении изменений: \(error.localizedDescription)")
        }
    }

    // MARK: - Удаление

    func deleteTraining(context: NSManagedObjectContext, onDelete: @escaping () -> Void) {
        context.delete(training)
        do {
            try context.save()
            onDelete()
        } catch {
            print("❌ Ошибка при удалении: \(error.localizedDescription)")
        }
    }

    // MARK: - Баланс

    private func updateBalancesIfNeeded(clients: FetchedResults<Client>) {
        let statusesToDeduct: [TrainingStatus] = [.completed, .cancelledAndPaid]
        let oldStatus = TrainingStatus(rawValue: originalStatus) ?? .planned

        if !statusesToDeduct.contains(oldStatus), statusesToDeduct.contains(status) {
            for client in clients {
                guard let id = client.id else { continue }
                if selectedClients.contains(id),
                   let balances = client.balances as? Set<TrainingBalance>,
                   let balance = balances.first(where: { $0.type == selectedType.rawValue && $0.count > 0 }) {
                    balance.count -= 1
                }
            }
        }

        if statusesToDeduct.contains(oldStatus), !statusesToDeduct.contains(status) {
            for client in clients {
                guard let id = client.id else { continue }
                if selectedClients.contains(id),
                   let balances = client.balances as? Set<TrainingBalance>,
                   let balance = balances.first(where: { $0.type == selectedType.rawValue }) {
                    balance.count += 1
                }
            }
        }
    }
}

