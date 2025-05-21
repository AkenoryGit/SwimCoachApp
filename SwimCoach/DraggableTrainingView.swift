//
//  DraggableTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI

struct DraggableTrainingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var offset: CGFloat = 0
    @State private var showAlert = false
    @State private var originalOffset: CGFloat = 0
    @State private var newStartDate: Date = Date()

    let positionedTraining: PositionedTraining
    let hourHeight: CGFloat

    var body: some View {
        let training = positionedTraining.training

        VStack(alignment: .leading, spacing: 4) {
            Text(training.type ?? "Без типа")
                .font(.headline)

            if let clients = training.clients as? Set<Client>, !clients.isEmpty {
                Text(clients.map { $0.fullName ?? "Без имени" }
                        .sorted()
                        .joined(separator: ", "))
                    .font(.caption)
            }

            if let start = training.date, let end = training.endTime {
                Text("\(formatTime(start))–\(formatTime(end))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(8)
        .offset(y: offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation.height + originalOffset
                }
                .onEnded { value in
                    let totalOffset = value.translation.height + originalOffset
                    let newStartTime = calculateNewTime(offset: totalOffset)
                    newStartDate = newStartTime
                    showAlert = true
                }
        )
        .alert("Изменить время тренировки?", isPresented: $showAlert) {
            Button("Отменить", role: .cancel) {
                offset = originalOffset // откатить назад
            }
            Button("Изменить", role: .destructive) {
                updateTrainingTime(to: newStartDate)
            }
        } message: {
            Text("Новое начало: \(formatTime(newStartDate))")
        }
        .position(x: UIScreen.main.bounds.width / 2, y: positionedTraining.topOffset + offset + positionedTraining.height / 2)
        .frame(height: positionedTraining.height)
        .onAppear {
            originalOffset = 0
        }
    }

    private func calculateNewTime(offset: CGFloat) -> Date {
        let minutes = offset / hourHeight * 60
        guard let originalDate = positionedTraining.training.date else { return Date() }
        return Calendar.current.date(byAdding: .minute, value: Int(minutes), to: originalDate) ?? originalDate
    }

    private func updateTrainingTime(to newStart: Date) {
        guard let oldStart = positionedTraining.training.date,
              let oldEnd = positionedTraining.training.endTime else { return }

        let duration = oldEnd.timeIntervalSince(oldStart)
        let newEnd = newStart.addingTimeInterval(duration)

        positionedTraining.training.date = newStart
        positionedTraining.training.endTime = newEnd

        do {
            try viewContext.save()
            TrainingUpdateNotifier.shared.notifyUpdate()
        } catch {
            print("Ошибка сохранения после перетаскивания: \(error.localizedDescription)")
        }

        offset = 0
        originalOffset = 0
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
