//
//  EditDutyViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 18.06.2025.
//

import Foundation
import SwiftUI
import CoreData

// Эта модель используется для редактирования дежурства
class EditDutyViewModel: ObservableObject {
    @Published var note: String // текст заметки
    @Published var startTime: Date // дата и время начала дежурства
    @Published var endTime: Date // дата и время окончания дежурства
    @Published var selectedTrainer: Trainer? // выбранный тренер
    @Published var selectedStatus: String // статус дежурства (например, "Запланирована", "Проведена", "Отменена")

    let duty: Duty // объект дежурства, который мы редактируем
    let allTrainers: [Trainer] = mockTrainers // список всех тренеров, доступных для выбора
    let allStatuses = ["Запланирована", "Проведена", "Отменена"] // список всех возможных статусов дежурства

    init(duty: Duty) { // Инициализируем модель с существующим объектом дежурства
        self.duty = duty // сохраняем ссылку на объект дежурства
        self.note = duty.note ?? "" // инициализируем текст заметки, если он есть, иначе пустой строкой
        self.selectedTrainer = mockTrainers.first(where: { $0.fullName == duty.trainerName }) // ищем тренера по имени в списке доступных тренеров
        self.selectedStatus = duty.status ?? "Запланирована" // инициализируем статус дежурства, если он есть, иначе "Запланирована"

        let calendar = Calendar.current // используем календарь для работы с датами
        let componentsStart = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: duty.startTime ?? Date()) // получаем компоненты даты и времени начала дежурства
        let componentsEnd = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: duty.endTime ?? Date()) // получаем компоненты даты и времени окончания дежурства

        self.startTime = calendar.date(from: componentsStart) ?? Date() // инициализируем дату начала дежурства, если не удалось получить дату, используем текущую
        self.endTime = calendar.date(from: componentsEnd) ?? Date() // инициализируем дату окончания дежурства, если не удалось получить дату, используем текущую
    }

    func save(context: NSManagedObjectContext, dismiss: @escaping () -> Void) {
        guard startTime < endTime else {
            print("❌ Время начала не может быть позже или равно времени окончания")
            return
        }

        // Функция для сохранения изменений в дежурстве
        duty.note = note
        duty.startTime = startTime
        duty.endTime = endTime
        duty.trainerName = selectedTrainer?.fullName
        duty.status = selectedStatus

        do {
            try context.save()
            print("✅ Дежурство обновлено")
            dismiss()
        } catch {
            print("❌ Ошибка при сохранении: \(error.localizedDescription)")
        }
    }

    func delete(context: NSManagedObjectContext, dismiss: @escaping () -> Void) { // Функция для удаления дежурства
        context.delete(duty) // удаляем объект дежурства из контекста

        do { // пытаемся сохранить изменения в контексте
            try context.save() // если сохранение прошло успешно
            print("🗑️ Дежурство удалено") // выводим сообщение об успешном удалении
            dismiss() // закрываем текущий экран
        } catch { // если произошла ошибка при сохранении
            print("❌ Ошибка при удалении: \(error.localizedDescription)") // выводим сообщение об ошибке
        }
    }
}
