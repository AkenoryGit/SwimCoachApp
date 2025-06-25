//
//  ScheduleView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI
import CoreData

// MARK: - Главный экран с календарём и таймлайном

struct ScheduleView: View {

    // MARK: - Состояния и окружение

    /// Выбранная дата в календаре
    @State private var selectedDate = Date()

    /// Контекст Core Data
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Тело вьюшки

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Календарь
                CalendarView(selectedDate: $selectedDate)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 8) {
                    // MARK: - Переключение дней
                    HStack {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.left")
                        }

                        Spacer()

                        Text(dateFormatter.string(from: selectedDate))
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Таймлайн на день
                    ZStack(alignment: .topLeading) {
                        DayTimelineView(selectedDate: $selectedDate)
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Кнопка добавления тренировки
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTrainingView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                // Обновляем статусы тренировок при открытии экрана
                TrainingUpdateNotifier.shared.updateStatusesIfNeeded(context: viewContext)
            }
        }
    }

    // MARK: - Форматтер даты для отображения в заголовке

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
} 
