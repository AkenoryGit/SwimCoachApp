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
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var onTrainingChanged: (() -> Void)? = nil

    @State private var nowOffset: CGFloat? = currentTimeOffset()
    @State private var selectedTraining: Training?
    @State private var trainings: [Training] = []
    @State private var refreshTrigger = UUID()
    @State private var duties: [Duty] = []

    var body: some View {
        let _ = refreshTrigger
        let positionedTrainings = calculatePositionedTrainings(from: trainings, hourHeight: hourHeight)
        let positionedDuties = calculatePositionedDuties(from: duties, hourHeight: hourHeight)

        ScrollView(.vertical) {
            HStack(spacing: 0) {
                // Время
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(6..<24) { hour in
                        Text(String(format: "%02d:00", hour))
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(height: hourHeight, alignment: .topTrailing)
                            .padding(.trailing, 4)
                    }
                }
                .frame(width: 50)
                .padding(.leading, 8)

                // Сетка, линия времени, тренировки и дежурства
                ZStack(alignment: .topLeading) {
                    TimelineBackgroundView(hourHeight: hourHeight)

                    if Calendar.current.isDateInToday(selectedDate),
                       let offset = nowOffset {
                        Rectangle()
                            .fill(Color.red)
                            .frame(height: 1)
                            .offset(y: offset - 0.5)
                    }

                    HStack(spacing: 0) {
                        TrainingTimelineLayer(
                            positionedTrainings: positionedTrainings,
                            selectedTraining: $selectedTraining,
                            selectedDate: selectedDate,
                            onTrainingChanged: {
                                fetchData()
                                refreshTrigger = UUID()
                            }
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.7)

                        DutyTimelineLayer(positionedDuties: positionedDuties)
                            .frame(width: UIScreen.main.bounds.width * 0.3)
                    }
                }
            }
            .frame(minHeight: CGFloat(18) * hourHeight)
        }
        .padding(.leading, 88)
        .background(Color.white)
        .onReceive(timer) { _ in
            nowOffset = currentTimeOffset()
        }
        .onAppear { fetchData() }
        .onChange(of: selectedDate) { _ in fetchData() }
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    if abs(value.translation.width) > 50 && abs(value.translation.height) < 20 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedDate = Calendar.current.date(byAdding: .day, value: value.translation.width < 0 ? 1 : -1, to: selectedDate) ?? selectedDate
                        }
                    }
                }
        )
    }

    private func fetchData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let trainingRequest = NSFetchRequest<Training>(entityName: "Training")
        trainingRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Training.date, ascending: true)]
        trainingRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

        let dutyRequest = NSFetchRequest<Duty>(entityName: "Duty")
        dutyRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Duty.startTime, ascending: true)]
        dutyRequest.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            trainings = try viewContext.fetch(trainingRequest)
            duties = try viewContext.fetch(dutyRequest)
        } catch {
            print("Ошибка при загрузке данных: \(error)")
            trainings = []
            duties = []
        }
    }
}

struct TimelineBackgroundView: View {
    let hourHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(6..<24) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                Spacer()
                    .frame(height: hourHeight - 1)
            }
        }
        .background(Color.white)
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
    var onTrainingChanged: (() -> Void)? = nil

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
                DraggableTrainingView(
                    positionedTraining: item,
                    hourHeight: 60,
                    onTrainingChanged: {
                        onTrainingChanged?() // вызовем если задан
                    }
                )
                .padding(.leading, 10)
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


