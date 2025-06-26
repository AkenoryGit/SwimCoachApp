//
//  AddCoachView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI
import CoreData

struct AddCoachView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var specialty = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Данные тренера")) {
                    TextField("ФИО", text: $fullName)
                    TextField("Специализация", text: $specialty)
                }
            }
            .navigationTitle("Новый тренер")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveCoach()
                        dismiss()
                    }
                    .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveCoach() {
        let newCoach = CoachData(context: viewContext)
        newCoach.id = UUID()
        newCoach.fullName = fullName
        newCoach.specialty = specialty
        newCoach.isMarkedDeleted = false

        do {
            try viewContext.save()
        } catch {
            print("❌ Ошибка при сохранении тренера: \(error.localizedDescription)")
        }
    }
}
