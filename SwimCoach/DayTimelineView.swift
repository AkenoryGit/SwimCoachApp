//
//  DayTimelineView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI
import CoreData

struct DayTimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date
    private let hourHeight: CGFloat = 60

    @State private var selectedTraining: Training?
    @State private var trainings: [Training] = []

    var body: some View {
        let positioned = calculatePositionedTrainings(from: trainings, hourHeight: hourHeight)

        ScrollView {
            ZStack(alignment: .topLeading) {
                // Сетка времени
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

                // Слой с тренировками
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
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    if abs(value.translation.width) > 50 && abs(value.translation.height) < 20 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if value.translation.width < 0 {
                                // Свайп влево — следующий день
                                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                            } else {
                                // Свайп вправо — предыдущий день
                                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                            }
                        }
                    }
                }
        )
        .onAppear {
            fetchTrainings()
        }
        .onChange(of: selectedDate) { _ in
            fetchTrainings()
        }
    }

    private func fetchTrainings() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = NSFetchRequest<Training>(entityName: "Training")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Training.date, ascending: true)]
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            trainings = try viewContext.fetch(request)
        } catch {
            print("❌ Ошибка при загрузке тренировок: \(error)")
            trainings = []
        }
    }
}

struct PositionedTraining: Identifiable {
    var id: NSManagedObjectID { training.objectID }
    let training: Training
    let topOffset: CGFloat
    let height: CGFloat
}

func calculatePositionedTrainings(from trainings: [Training], hourHeight: CGFloat) -> [PositionedTraining] {
    return trainings.compactMap { makePositionedTraining(from: $0, hourHeight: hourHeight) }
}

func makePositionedTraining(from training: Training, hourHeight: CGFloat) -> PositionedTraining? {
    guard let start = training.date,
          let end = training.endTime else { return nil }

    let calendar = Calendar.current
    let minHour: CGFloat = 6

    let startComponents = calendar.dateComponents([.hour, .minute], from: start)
    let endComponents = calendar.dateComponents([.hour, .minute], from: end)

    let startTotalMinutes = CGFloat((startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0))
    let endTotalMinutes = CGFloat((endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0))

    let clampedStartMinutes = max(startTotalMinutes, 6 * 60)
    let clampedEndMinutes = min(endTotalMinutes, 23 * 60)

    let durationMinutes = clampedEndMinutes - clampedStartMinutes
    guard durationMinutes > 0 else { return nil }

    let topOffset = (clampedStartMinutes - minHour * 60)
    let height = durationMinutes
    
    print("📅 \(training.type ?? "Тип?") — \(training.date ?? .distantPast) ... \(training.endTime ?? .distantFuture)")

    return PositionedTraining(training: training, topOffset: topOffset, height: height)
}

struct TrainingTimelineLayer: View {
    let positionedTrainings: [PositionedTraining]
    @Binding var selectedTraining: Training?
    let selectedDate: Date

    @State private var nowOffset: CGFloat? = currentTimeOffset()
    
    // Публикуем таймер, который срабатывает каждую минуту
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

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
                DraggableTrainingView(positionedTraining: item, hourHeight: 60)
                    .padding(.leading, 60)
            }
        }
        // таймер безопасно обновляет `nowOffset`
        .onReceive(timer) { _ in
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
