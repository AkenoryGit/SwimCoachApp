////
////  SelectedDayTrainingsView.swift
////  SwimCoach
////
////  Created by Дмитрий Дудник on 19.05.2025.
////
//
//import SwiftUI
//import CoreData
//import Combine
//
//// MARK: - Экран со списком тренировок на выбранную дату
//
///// Отображает список всех тренировок (и дежурств) на конкретную дату.
///// Позволяет перейти к редактированию и удалять записи.
//struct SelectedDayTrainingsView: View {
//
//    // MARK: - Внешние зависимости
//
//    /// Контекст Core Data из окружения
//    @Environment(\.managedObjectContext) private var viewContext
//
//    /// Синглтон, отслеживающий изменения тренировок в других частях приложения
//    @ObservedObject private var trainingNotifier = TrainingUpdateNotifier.shared
//
//    // MARK: - Состояния
//
//    /// Триггер для перерисовки списка (например, после удаления)
//    @State private var refreshTrigger = false
//
//    /// Показывать ли алерт удаления
//    @State private var showDeleteAlert = false
//
//    /// Тренировка, которую пользователь хочет удалить
//    @State private var trainingToDelete: Training?
//
//    // MARK: - Входные данные
//
//    /// Дата, для которой нужно отобразить тренировки
//    let selectedDate: Date
//
//    // MARK: - Запрос к Core Data на тренировки выбранного дня
//
//    /// Список тренировок на выбранную дату
//    @FetchRequest var trainings: FetchedResults<Training>
//
//    /// Инициализатор, который формирует `FetchRequest` на выбранную дату
//    init(selectedDate: Date) {
//        self.selectedDate = selectedDate
//
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: selectedDate)
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//
//        // Фильтрация: берем только тренировки в пределах дня
//        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
//
//        _trainings = FetchRequest(
//            sortDescriptors: [NSSortDescriptor(keyPath: \Training.date, ascending: true)],
//            predicate: predicate,
//            animation: .default
//        )
//    }
//
//    // MARK: - Основной UI
//
//    var body: some View {
//        List {
//            Section(
//                header: Text("Тренировки на выбранную дату:")
//                    .font(.title3)
//                    .bold()
//            ) {
//                // Если тренировок нет — показываем заглушку
//                if trainings.isEmpty {
//                    Text("Нет тренировок на этот день")
//                        .foregroundColor(.gray)
//                        .font(.subheadline)
//                } else {
//                    // Иначе отображаем список тренировок
//                    ForEach(trainings) { training in
//                        trainingRow(for: training)
//                    }
//                }
//            }
//        }
//        .id(refreshTrigger) // заставляем SwiftUI пересоздать список при изменении
//        .padding()
//        .onChange(of: trainingNotifier.didChange) {
//            refreshTrigger.toggle() // реакция на внешние изменения тренировок
//        }
//        .alert(isPresented: $showDeleteAlert) {
//            deleteAlert
//        }
//        .onAppear {
//            // При первом появлении обновляем статусы устаревших тренировок
//            DispatchQueue.main.async {
//                TrainingUpdateNotifier.shared.updateStatusesIfNeeded(context: viewContext)
//            }
//        }
//    }
//
//    // MARK: - Одна строка в списке тренировок
//
//    /// Отображает одну строку с тренировкой (или дежурством)
//    private func trainingRow(for training: Training) -> some View {
//
//        // Переход на экран редактирования
//        let destination = EditTrainingView(
//            viewModel: EditTrainingViewModel(training: training),
//            onSave: {
//                TrainingUpdateNotifier.shared.notifyUpdate()
//            }
//        )
//
//        return NavigationLink(destination: destination) {
//            TrainingCardView(
//                training: training,
//                width: UIScreen.main.bounds.width * 0.9
//            )
//        }
//        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//            Button(role: .destructive) {
//                trainingToDelete = training
//                showDeleteAlert = true
//            } label: {
//                Label("Удалить", systemImage: "trash")
//            }
//        }
//    }
//
//    // MARK: - Алерт подтверждения удаления
//
//    private var deleteAlert: Alert {
//        Alert(
//            title: Text("Удалить тренировку?"),
//            message: Text("Это действие нельзя отменить."),
//            primaryButton: .destructive(Text("Удалить")) {
//                if let training = trainingToDelete {
//                    deleteTraining(training)
//                }
//            },
//            secondaryButton: .cancel()
//        )
//    }
//
//    // MARK: - Удаление тренировки
//
//    /// Удаляет тренировку из базы и обновляет интерфейс
//    private func deleteTraining(_ training: Training) {
//        withAnimation {
//            viewContext.delete(training)
//            do {
//                try viewContext.save()
//                TrainingUpdateNotifier.shared.notifyUpdate()
//            } catch {
//                print("❌ Ошибка при удалении тренировки: \(error.localizedDescription)")
//            }
//        }
//    }
//}
