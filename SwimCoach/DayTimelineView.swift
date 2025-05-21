//
//  DayTimelineView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI

struct DayTimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let selectedDate: Date
    private let hourHeight: CGFloat = 60

    @FetchRequest var trainings: FetchedResults<Training>
    @State private var selectedTraining: Training?

    init(selectedDate: Date) {
        self.selectedDate = selectedDate

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        _trainings = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Training.date, ascending: true)],
            predicate: NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate),
            animation: .default
        )
    }

    var body: some View {
        let positioned = calculatePositionedTrainings(from: Array(trainings), hourHeight: hourHeight)

        ScrollView {
            ZStack(alignment: .topLeading) {
                // Сетка часов
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(6..<23, id: \.self) { hour in
                        HStack(alignment: .top) {
                            Text(String(format: "%02d:00", hour))
                                .frame(width: 50, alignment: .trailing)
                                .font(.caption)
                                .padding(.trailing, 4)

                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 0.5)
                        }
                        .frame(height: hourHeight)
                    }
                }
                .offset(y: -23)
                // Тренировки
                TrainingTimelineLayer(
                    positionedTrainings: positioned,
                    selectedTraining: $selectedTraining,
                    selectedDate: selectedDate
                )
            }
            .sheet(item: $selectedTraining) { training in
                EditTrainingView(training: training)
            }
            .padding(.vertical)
        }
    }
}

struct PositionedTraining: Identifiable {
    let id = UUID()
    let training: Training
    let topOffset: CGFloat
    let height: CGFloat
}

func calculatePositionedTrainings(from trainings: [Training], hourHeight: CGFloat) -> [PositionedTraining] {
    let calendar = Calendar.current
    let minHour: CGFloat = 6

    return trainings.compactMap { training in
        guard let start = training.date, let end = training.endTime else { return nil }

        let startComponents = calendar.dateComponents([.hour, .minute], from: start)
        let endComponents = calendar.dateComponents([.hour, .minute], from: end)

        let startTotalMinutes = CGFloat((startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0))
        let endTotalMinutes = CGFloat((endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0))

        let clampedStartMinutes = max(startTotalMinutes, 6 * 60)
        let clampedEndMinutes = min(endTotalMinutes, 23 * 60)

        let durationMinutes = clampedEndMinutes - clampedStartMinutes
        guard durationMinutes > 0 else { return nil }

        let topOffset = (clampedStartMinutes - minHour * 60)
        let height = durationMinutes // 1 минута = 1pt

        return PositionedTraining(
            training: training,
            topOffset: topOffset,
            height: height
        )
    }
}

struct TrainingTimelineLayer: View {
    let positionedTrainings: [PositionedTraining]
    @Binding var selectedTraining: Training?
    let selectedDate: Date

    @State private var nowOffset: CGFloat? = currentTimeOffset()

    var body: some View {
        ZStack(alignment: .topLeading) {
            if Calendar.current.isDateInToday(selectedDate),
               let offset = nowOffset {
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 1)
                    .offset(y: offset - 0.5)
                    .padding(.leading, 50)
            }

            ForEach(positionedTrainings) { item in
                TrainingCardView(training: item.training)
                    .frame(height: item.height)
                    .offset(y: item.topOffset)
                    .padding(.leading, 60)
                    .onTapGesture {
                        selectedTraining = item.training
                    }
            }
        }
        .onAppear(perform: startTimer)
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            nowOffset = currentTimeOffset()
        }
    }
}

func currentTimeOffset() -> CGFloat? {
    let calendar = Calendar.current
    let now = Date()
    let hourHeight: CGFloat = 60
    let minHour: CGFloat = 6

    let components = calendar.dateComponents([.hour, .minute], from: now)
    guard let hour = components.hour, let minute = components.minute else { return nil }

    let totalMinutes = CGFloat(hour * 60 + minute)
    let clampedMinutes = max(min(totalMinutes, 23 * 60), minHour * 60)

    return clampedMinutes - minHour * 60
}
