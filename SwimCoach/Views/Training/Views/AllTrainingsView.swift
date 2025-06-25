//
//  AllTrainingsView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

// MARK: - Экран отображения всех тренировок

struct AllTrainingsView: View {

    // MARK: - Среда окружения и состояние

    /// Контекст Core Data
    @Environment(\.managedObjectContext) private var viewContext

    /// ViewModel со списком тренировок
    @StateObject private var viewModel = AllTrainingsViewModel()

    // MARK: - Основной UI

    var body: some View {
        List {
            // Перебираем все тренировки и отображаем их
            ForEach(viewModel.trainings, id: \.id) { model in
                NavigationLink(destination: TrainingDetailView(training: model.training)) {
                    VStack(alignment: .leading) {
                        // Дата тренировки, форматированная по-русски
                        Text(model.startTime.formatted(
                            .dateTime
                                .day()
                                .month(.wide)
                                .year()
                                .locale(Locale(identifier: "ru_RU"))
                        ))

                        // Тип тренировки
                        Text(model.type)
                            .font(.subheadline)

                        // Список клиентов, если есть
                        if !model.clients.isEmpty {
                            Text("Клиенты: \(model.clients.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        // Загрузка данных при появлении экрана
        .onAppear {
            viewModel.fetchTrainings(context: viewContext)
        }
        .navigationTitle("Все тренировки")
    }
} 
