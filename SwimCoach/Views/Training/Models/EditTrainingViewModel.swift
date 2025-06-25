//
//  EditTrainingViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - ViewModel для редактирования существующей тренировки или дежурства

/// ViewModel, отвечающий за редактирование данных существующей тренировки или дежурства.
/// Используется экраном `EditTrainingView` для отображения и управления состоянием UI.
final class EditTrainingViewModel: ObservableObject, Identifiable {

    // MARK: - Идентификатор модели

    /// Уникальный идентификатор, соответствующий ID редактируемой тренировки
    var id: UUID { training.id ?? UUID() }

    // MARK: - Опубликованные свойства, связанные с UI

    /// Дата и время начала тренировки или дежурства
    @Published var date: Date

    /// Время окончания тренировки или дежурства
    @Published var endTime: Date

    /// Выбранный тип тренировки (только для тренировок)
    @Published var selectedType: TrainingType

    /// Выбранный бассейн (только для тренировок)
    @Published var selectedLocation: TrainingLocation

    /// Статус тренировки или дежурства (запланирована, проведена и т.д.)
    @Published var status: TrainingStatus

    /// Комментарий к тренировке или дежурству
    @Published var note: String

    /// Множество выбранных клиентов (используется только для тренировок)
    @Published var selectedClients: Set<UUID> = []

    /// Выбранный тренер для дежурства
    @Published var selectedTrainer: Trainer? = nil

    /// Флаг для показа alert при удалении
    @Published var showDeleteAlert = false

    /// Тип редактируемой записи — тренировка или дежурство
    @Published var entryType: EntryType = .training

    // MARK: - Приватные свойства

    /// Исходный статус, необходим для корректного пересчёта баланса занятий
    private let originalStatus: String

    /// Список доступных тренеров (заглушка)
    private(set) var allTrainers = mockTrainers

    /// Сохраняемая ссылка на объект тренировки из Core Data
    private let training: Training

    // MARK: - Инициализация

    /// Инициализирует ViewModel данными из переданной тренировки
    init(training: Training) {
        self.training = training
        self.date = training.date ?? Date()
        self.endTime = training.endTime ?? Date()
        self.selectedType = TrainingType(rawValue: training.type ?? "") ?? .personal
        self.selectedLocation = TrainingLocation(rawValue: training.location ?? "") ?? .bigPool
        self.status = TrainingStatus(rawValue: training.status ?? "") ?? .planned
        self.note = training.note ?? ""
        self.originalStatus = training.status ?? "Запланирована"

        // Определяем тип записи
        if training.type == "Дежурство" {
            self.entryType = .duty
        }

        // Пытаемся извлечь имя тренера из заметки
        if let trainerName = training.note?.components(separatedBy: ": ").last {
            self.selectedTrainer = allTrainers.first { $0.fullName == trainerName }
        }

        // Сохраняем список клиентов (если это тренировка)
        if let clients = training.clients as? Set<Client> {
            self.selectedClients = Set(clients.compactMap { $0.id })
        }
    }

    // MARK: - Обработка выбора клиента

    /// Добавляет или удаляет клиента из множества выбранных
    func toggleClientSelection(_ client: Client) {
        guard let id = client.id else { return }
        if selectedClients.contains(id) {
            selectedClients.remove(id)
        } else {
            selectedClients.insert(id)
        }
    }

    // MARK: - Сохранение изменений

    /// Сохраняет изменения тренировки или дежурства в Core Data
    func saveChanges(context: NSManagedObjectContext,
                     clients: FetchedResults<Client>,
                     onSave: (() -> Void)?) {

        if entryType == .duty {
            // Обновление дежурства
            training.type = "Дежурство"
            training.date = date
            training.endTime = endTime
            training.location = ""
            training.status = status.rawValue
            training.note = selectedTrainer != nil
                ? "[Дежурство за: \(selectedTrainer!.fullName)] \(note)"
                : note
            training.removeFromClients(training.clients ?? [])
        } else {
            // Обновление тренировки
            training.type = selectedType.rawValue
            training.location = selectedLocation.rawValue
            training.status = status.rawValue
            training.date = date
            training.endTime = endTime
            training.note = note

            // Обновляем список клиентов
            training.removeFromClients(training.clients ?? [])
            for client in clients {
                guard let id = client.id else { continue }
                if selectedClients.contains(id) {
                    training.addToClients(client)
                }
            }

            // Обновляем балансы при необходимости
            updateBalancesIfNeeded(clients: clients)
        }

        // Сохраняем в Core Data
        do {
            try context.save()
            onSave?()
            TrainingUpdateNotifier.shared.notifyUpdate()
        } catch {
            print("❌ Ошибка при сохранении изменений: \(error.localizedDescription)")
        }
    }

    // MARK: - Удаление тренировки

    /// Удаляет текущую тренировку из базы
    func deleteTraining(context: NSManagedObjectContext, onDelete: @escaping () -> Void) {
        context.delete(training)
        do {
            try context.save()
            onDelete()
        } catch {
            print("❌ Ошибка при удалении: \(error.localizedDescription)")
        }
    }

    // MARK: - Загрузка состояния при появлении

    func loadInitialState(activeClients: FetchedResults<Client>) {
        // Сохраняем ID клиентов, которые участвуют в текущей тренировке
        if let clients = training.clients as? Set<Client> {
            self.selectedClients = Set(clients.compactMap { $0.id })
        }

        // Пытаемся извлечь тренера из заметки, если это дежурство
        if training.type == "Дежурство",
           let trainerName = training.note?.components(separatedBy: ": ").last {
            self.selectedTrainer = allTrainers.first { $0.fullName == trainerName }
        }
    }
    
    // MARK: - Перерасчёт баланса при изменении статуса

    /// Учитывает изменение баланса занятий в зависимости от смены статуса тренировки
    private func updateBalancesIfNeeded(clients: FetchedResults<Client>) {
        let statusesToDeduct: [TrainingStatus] = [.completed, .cancelledAndPaid]
        let oldStatus = TrainingStatus(rawValue: originalStatus) ?? .planned

        if !statusesToDeduct.contains(oldStatus), statusesToDeduct.contains(status) {
            // Списание занятия
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
            // Возврат занятия
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

