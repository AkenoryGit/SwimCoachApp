//
//  SelectedDayTrainingsView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData
import Combine

struct SelectedDayTrainingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var trainingNotifier = TrainingUpdateNotifier.shared
    @State private var refreshTrigger = false
    @State private var showDeleteAlert = false
    @State private var trainingToDelete: Training?

    let selectedDate: Date

    @FetchRequest var trainings: FetchedResults<Training>

    init(selectedDate: Date) {
        self.selectedDate = selectedDate

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

        _trainings = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Training.date, ascending: true)],
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        let _ = refreshTrigger // триггер ререндеринга

        List {
            Section(header:
                Text("Тренировки на выбранную дату:")
                    .font(.title3)
                    .bold()
            ) {
                if trainings.isEmpty {
                    Text("Нет тренировок на этот день")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                } else {
                    ForEach(trainings) { training in
                        NavigationLink(destination: EditTrainingView(training: training)) {
                            TrainingCardView(training: training)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTraining(training)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .id(refreshTrigger)
        .padding()
        .onChange(of: trainingNotifier.didChange) {
            refreshTrigger.toggle()
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Удалить тренировку?"),
                message: Text("Это действие нельзя отменить."),
                primaryButton: .destructive(Text("Удалить")) {
                    if let training = trainingToDelete {
                        viewContext.delete(training)
                        do {
                            try viewContext.save()
                            TrainingUpdateNotifier.shared.notifyUpdate()
                        } catch {
                            print("Ошибка при удалении тренировки: \(error.localizedDescription)")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            DispatchQueue.main.async {
                TrainingUpdateNotifier.shared.updateStatusesIfNeeded(context: viewContext)
            }
        }
    }
    private func deleteTraining(_ training: Training) {
        withAnimation {
            viewContext.delete(training)
            do {
                try viewContext.save()
            } catch {
                print("Ошибка при удалении тренировки: \(error.localizedDescription)")
            }
        }
    }
}
