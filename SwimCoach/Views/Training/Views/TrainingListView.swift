//
//  TrainingListView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData

// MARK: - TrainingListView
// Отображает список всех тренировок с возможностью перейти к их подробностям
struct TrainingListView: View {
    // Контекст Core Data
    @Environment(\.managedObjectContext) private var viewContext

    // Запрос всех тренировок, отсортированных по дате убыванию
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Training.date, ascending: false)],
        animation: .default
    )
    private var trainings: FetchedResults<Training>

    var body: some View {
        List {
            ForEach(trainings) { training in
                NavigationLink(destination: TrainingDetailView(training: training)) {
                    VStack(alignment: .leading, spacing: 4) {
                        // MARK: - Дата и тип тренировки
                        Text(training.date?.formatted(
                            .dateTime
                                .day()
                                .month(.abbreviated)
                                .year()
                                .hour()
                                .minute()
                                .locale(Locale(identifier: "ru_RU"))
                        ) ?? "Без даты")
                        .font(.headline)

                        Text(training.type ?? "Без типа")
                            .foregroundColor(.secondary)

                        // MARK: - Статус
                        Text("Статус: \(training.status ?? "неизвестно")")
                            .font(.caption)

                        // MARK: - Список клиентов
                        if let clients = training.clients as? Set<Client>, !clients.isEmpty {
                            Text("Клиенты: \(clients.map { $0.fullName ?? "Без имени" }.joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Все тренировки")
    }
}
