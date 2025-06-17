//
//  AllTrainingsView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

struct AllTrainingsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Загружаем тренировки, отсортированные по дате
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Training.date, ascending: false)],
        animation: .default
    )
    private var trainings: FetchedResults<Training>

    var body: some View {
        List {
            ForEach(trainings) { training in
                NavigationLink(destination: TrainingDetailView(training: training)) {
                    VStack(alignment: .leading) {
                        Text(
                            training.date.map {
                                $0.formatted(
                                    .dateTime
                                        .day()
                                        .month(.wide)
                                        .year()
                                        .locale(Locale(identifier: "ru_RU"))
                                )
                            } ?? "Без даты"
                        )

                        Text(training.type ?? "Без типа")
                            .font(.subheadline)

                        if let clients = training.clients as? Set<Client> {
                            Text("Клиенты: \(clients.compactMap { $0.fullName }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear {
            updateStatusesIfNeeded()
        }
        .navigationTitle("Все тренировки")
    }
    private func updateStatusesIfNeeded() {
        for training in trainings {
            guard training.status == "Запланирована",
                  let endTime = training.endTime,
                  endTime < Date() else { continue }

            training.status = "Проведена"

            if let clients = training.clients as? Set<Client> {
                for client in clients {
                    if let balances = client.balances as? Set<TrainingBalance>,
                       let balance = balances.first(where: { $0.type == training.type && $0.count > 0 }) {
                        balance.count -= 1
                    }
                }
            }
        }

        do {
            try viewContext.save()
        } catch {
            print("Ошибка при обновлении статусов тренировок: \(error.localizedDescription)")
        }
    }
}
