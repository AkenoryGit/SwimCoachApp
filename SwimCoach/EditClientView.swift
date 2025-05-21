//
//  EditClientView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

struct EditClientView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var client: Client
    
    @State private var fullName: String = ""
    @State private var birthDate: Date = Date()
    @State private var phone: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Имя")) {
                    TextField("Имя", text: $fullName)
                }
                
                Section(header: Text("Дата рождения")) {
                    DatePicker("Выберите дату", selection: $birthDate, displayedComponents: .date)
                }
                
                Section(header: Text("Телефон")) {
                    TextField("Телефон", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Примечания")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
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
                fullName = client.fullName ?? ""
                birthDate = client.birthDate ?? Date()
                phone = client.phone ?? ""
                notes = client.notes ?? ""
            }
        }
    }

    private func saveChanges() {
        client.fullName = fullName
        client.birthDate = birthDate
        client.phone = phone
        client.notes = notes

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Ошибка при сохранении клиента: \(error.localizedDescription)")
        }
    }
}
