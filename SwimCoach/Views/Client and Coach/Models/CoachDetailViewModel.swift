//
//  CoachDetailViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI
import CoreData

// ViewModel для отображения и управления карточкой тренера
class CoachDetailViewModel: ObservableObject {
    @Published var coach: CoachData                           // Модель тренера
    @Published var showingDeleteAlert = false                 // Флаг показа алерта удаления
    @Published var showingEditForm = false                    // Флаг показа формы редактирования
    @Published var selectedCoachIDs: Set<UUID> = []
    @Published var showingProtectedCoachAlert = false

    init(coach: CoachData) {
        self.coach = coach
    }

    // Полное имя тренера или "Без имени"
    var fullName: String {
        coach.fullName ?? "Без имени"
    }

    // Специализация тренера
    var specialty: String {
        coach.specialty ?? "Не указана"
    }

    // Удаление тренера (установка флага isMarkedDeleted)
    func deleteCoach(context: NSManagedObjectContext, dismiss: @escaping () -> Void) {
        coach.isMarkedDeleted = true
        do {
            try context.save()
            dismiss()
        } catch {
            print("❌ Ошибка при удалении тренера: \(error.localizedDescription)")
        }
    }
}
