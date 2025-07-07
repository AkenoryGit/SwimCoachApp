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
    @State private var showDuplicateAlert = false
    @State private var allowSavingDuplicate = false

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
                        if allowSavingDuplicate || !doesCoachExist(with: fullName) {
                            saveCoach()
                            dismiss()
                        } else {
                            showDuplicateAlert = true
                        }
                    }
                    .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Тренер с таким ФИО уже существует", isPresented: $showDuplicateAlert) {
                Button("Отменить", role: .cancel) {
                    allowSavingDuplicate = false
                }
                Button("Создать всё равно", role: .destructive) {
                    allowSavingDuplicate = true
                    saveCoach()
                    dismiss()
                }
            } message: {
                Text("Вы уверены, что хотите создать тренера с таким же именем?")
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
    private func doesCoachExist(with name: String) -> Bool {
        let request: NSFetchRequest<CoachData> = CoachData.fetchRequest()
        request.predicate = NSPredicate(format: "fullName ==[cd] %@", name.trimmingCharacters(in: .whitespacesAndNewlines))

        do {
            let result = try viewContext.fetch(request)
            return !result.isEmpty
        } catch {
            print("❌ Ошибка при проверке дубликатов: \(error.localizedDescription)")
            return false
        }
    }
}
