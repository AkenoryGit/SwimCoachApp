//
//  TrainingDetailView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

// MARK: - Детальный просмотр тренировки

struct TrainingDetailView: View {

    // MARK: - Окружение и зависимости

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let training: Training

    @State private var showingDeleteAlert = false

    // MARK: - Основной UI

    var body: some View {
        Form {
            // MARK: - Основная информация
            Section(header: Text("Основное")) {
                let dateFormatter = Date.FormatStyle.dateTime
                    .locale(Locale(identifier: "ru_RU"))
                    .day()
                    .month(.abbreviated)
                    .year()
                    .hour()
                    .minute()

                Text("Дата: \(training.date?.formatted(dateFormatter) ?? "неизвестно")")
                Text("Тип: \(training.type ?? "неизвестно")")
                Text("Статус: \(training.status ?? "неизвестно")")
            }

            // MARK: - Заметка, если есть
            if let note = training.note, !note.isEmpty {
                Section(header: Text("Заметка")) {
                    Text(note)
                }
            }

            // MARK: - Клиенты, если есть
            if let clients = training.clients as? Set<Client>, !clients.isEmpty {
                Section(header: Text("Клиенты")) {
                    ForEach(Array(clients), id: \.self) { client in
                        Text(client.fullName ?? "Без имени")
                    }
                }
            }
        }
        .navigationTitle("Тренировка")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
        }
        .alert("Удалить тренировку?", isPresented: $showingDeleteAlert) {
            Button("Удалить", role: .destructive) {
                deleteTraining()
            }
            Button("Отмена", role: .cancel) {}
        }
    }

    // MARK: - Удаление тренировки

    private func deleteTraining() {
        viewContext.delete(training)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Ошибка при удалении тренировки: \(error.localizedDescription)")
        }
    }
} 
