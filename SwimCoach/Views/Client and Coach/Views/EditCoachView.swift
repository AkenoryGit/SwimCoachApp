//
//  EditCoachView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI

struct EditCoachView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var coach: CoachData

    @State private var fullName: String = ""
    @State private var specialty: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("ФИО")) {
                    TextField("ФИО", text: $fullName)
                }

                Section(header: Text("Специализация")) {
                    TextField("Специализация", text: $specialty)
                }
            }
            .navigationTitle("Редактировать")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                fullName = coach.fullName ?? ""
                specialty = coach.specialty ?? ""
            }
        }
    }

    private func saveChanges() {
        coach.fullName = fullName
        coach.specialty = specialty

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Ошибка при сохранении тренера: \(error.localizedDescription)")
        }
    }
}
