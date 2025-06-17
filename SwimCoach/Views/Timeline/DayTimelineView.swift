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
    private let fixedTimelineWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    private let leftBound: CGFloat = 60
    private var rightBound: CGFloat { fixedTimelineWidth - 16 }

    @State private var nowOffset: CGFloat? = currentTimeOffset()
    @State private var selectedTraining: Training?
    @State private var trainings: [Training] = []
    @State private var refreshTrigger = UUID()
    @State private var duties: [Duty] = []
    @State private var selectedDuty: Duty?
    private let leftTimeAreaOffset: CGFloat = 35
    private let rightTimeAreaOffset: CGFloat = UIScreen.main.bounds.width * 0.75 - 10

    var body: some View {
        let adjustedLeftBound = leftTimeAreaOffset + 20
        let adjustedRightBound = rightTimeAreaOffset + 20
        let _ = refreshTrigger
        let _ = print("♻️ Refresh trigger: \(refreshTrigger)")
        let positionedTrainings = calculatePositionedTrainings(from: trainings, hourHeight: hourHeight)
        let positionedDuties = makePositionedDuties(from: duties, on: selectedDate, hourHeight: hourHeight)
        let fixedTimelineWidth: CGFloat = UIScreen.main.bounds.width * 0.75

        ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        Color.clear
                            .frame(height: hourHeight / 2) // ← отступ в 30 минут
                        TimelineBackgroundView(hourHeight: hourHeight, fixedWidth: fixedTimelineWidth) 

                        if Calendar.current.isDateInToday(selectedDate),
                           let offset = nowOffset {
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 1)
                                .offset(y: offset - 0.5 + hourHeight / 2) // ← ⚠️ смещаем тоже
                                .padding(.leading, 60)
                        }
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 2)
                            .offset(x: adjustedLeftBound, y: hourHeight / 2)

                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 2)
                            .offset(x: adjustedRightBound, y: hourHeight / 2)

                        TrainingTimelineLayer(
                            positionedTrainings: positionedTrainings,
                            selectedTraining: $selectedTraining,
                            selectedDate: selectedDate,
                            leftBound: adjustedLeftBound,
                            rightBound: adjustedRightBound,
                            onTrainingChanged: {
                                fetchData()
                                refreshTrigger = UUID()
                            },
                            fixedWidth: fixedTimelineWidth,
                            hourHeight: hourHeight // ← передаём сюда
                        )
                        .id(refreshTrigger)
                        .offset(y: hourHeight / 2)
                        .frame(width: fixedTimelineWidth)
                        .frame(height: CGFloat(18) * hourHeight)

                        DutyTimelineLayer(
                            positionedDuties: positionedDuties,
                            hourHeight: hourHeight,
                            onDutyTapped: { duty in
                                selectedDuty = duty
                            }
                        )
                        .frame(width: 40)
                        .offset(y: hourHeight / 2)
                        .offset(x: UIScreen.main.bounds.width * 0.815)
                    }
                    .frame(height: CGFloat(18) * hourHeight)
                }
            }
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
        .onAppear {
            print("🧩 Duties перед отображением: \(duties.map { "\($0.startTime ?? Date()) — \($0.endTime ?? Date())" })")
        }
        .sheet(item: $selectedDuty, onDismiss: {
            fetchData()
            refreshTrigger = UUID()  // 💥 форсируем обновление ZStack и его поддеревьев
        }) { duty in
            EditDutyView(duty: duty)
        }
        .sheet(item: $selectedTraining, onDismiss: {
            selectedTraining = nil
        }) { training in
            EditTrainingView(
                training: training,
                entryType: .constant(training.type == "Дежурство" ? .duty : .training),
                onSave: {
                    fetchData()
                    refreshTrigger = UUID()
                    selectedTraining = nil // ← если нужно точно сбросить
                }
            )
        }
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
            
            let dutiesFetched = try viewContext.fetch(dutyRequest)
            for duty in dutiesFetched {
                print("📘 Дежурство: \(duty.startTime?.formatted() ?? "нет времени") → \(duty.endTime?.formatted() ?? "нет времени")")
            }
            duties = dutiesFetched
            
            duties = try viewContext.fetch(dutyRequest)
            print("✅ Trainings: \(trainings.count), Duties: \(duties.count)")
            for d in duties {
                print("📘 Duty from \(d.startTime) to \(d.endTime)")
            }
        } catch {
            print("Ошибка при загрузке данных: \(error)")
            trainings = []
            duties = []
        }
    }
}

struct TimelineBackgroundView: View {
    let hourHeight: CGFloat
    let fixedWidth: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(6..<24) { hour in
                HStack(spacing: 0) {
                    Text(String(format: "%02d:00", hour))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 50, alignment: .trailing)
                        .padding(.trailing, 4)

                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)

                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: hourHeight)
            }
        }
        .frame(width: fixedWidth, height: hourHeight * 18)
    }
}

struct PositionedTraining: Identifiable {
    var id: NSManagedObjectID { training.objectID }
    let training: Training
    let topOffset: CGFloat
    let height: CGFloat
    let column: Int         // ← в каком "столбце"
    let totalColumns: Int   // ← сколько всего параллельных тренировок в этом блоке
}

func calculatePositionedTrainings(from trainings: [Training], hourHeight: CGFloat) -> [PositionedTraining] {
    let sorted = trainings.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }

    var result: [PositionedTraining] = []
    var currentGroup: [Training] = []

    func addGroup(_ group: [Training]) {
        let count = group.count
        for (index, training) in group.enumerated() {
            if let (topOffset, height) = makeTrainingOffsetHeight(from: training, hourHeight: hourHeight) {
                let item = PositionedTraining(
                    training: training,
                    topOffset: topOffset,
                    height: height,
                    column: index,
                    totalColumns: count
                )
                result.append(item)
            }
        }
    }

    for training in sorted {
        guard let start = training.date, let end = training.endTime else { continue }

        if currentGroup.isEmpty {
            currentGroup.append(training)
        } else {
            let overlaps = currentGroup.contains { other in
                guard let otherStart = other.date, let otherEnd = other.endTime else { return false }
                return max(start, otherStart) < min(end, otherEnd)
            }

            if overlaps {
                currentGroup.append(training)
            } else {
                addGroup(currentGroup)
                currentGroup = [training]
            }
        }
    }

    if !currentGroup.isEmpty {
        addGroup(currentGroup)
    }

    return result
}

func makePositionedDuties(from duties: [Duty], on day: Date, hourHeight: CGFloat) -> [PositionedDuty] {
    let calendar = Calendar.current
    let timeZoneOffset = TimeInterval(TimeZone.current.secondsFromGMT(for: day))

    // 6 утра в UTC, потому что даты сохраняются в UTC
    let sixAMUTC = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: day)!

    return duties.compactMap { duty in
        guard let start = duty.startTime, let end = duty.endTime else { return nil }

        // Считаем разницу в минутах от 6:00 UTC
        let startMinutes = CGFloat(start.timeIntervalSince(sixAMUTC)) / 60.0
        let endMinutes = CGFloat(end.timeIntervalSince(sixAMUTC)) / 60.0
        let duration = endMinutes - startMinutes

        guard duration > 0 else { return nil }

        // Время сохраняется в UTC, а шкала рисуется от 6:00 локального дня.
        // Чтобы избежать ошибок из-за таймзоны, считаем смещение от 6:00 UTC напрямую.
        // Делим offset на 2, чтобы компенсировать визуальный сдвиг (из-за отступа в DayTimelineView).
        let minuteHeight = hourHeight / 60.0
        let topOffset = startMinutes * minuteHeight / 2
        let height = duration * minuteHeight

        print("🟡 \(duty.trainerName ?? "") — offset: \(topOffset), height: \(height)")
        print("🧪 RAW UTC startTime:", start)
        print("🧪 RAW UTC endTime:", end)

        return PositionedDuty(duty: duty, topOffset: topOffset, height: height)
    }
}

func makePositionedTraining(from training: Training, hourHeight: CGFloat, column: Int, totalColumns: Int) -> PositionedTraining? {
    guard let start = training.date, let end = training.endTime else { return nil }
    let calendar = Calendar.current
    let minHour: CGFloat = 6

    let startOfDay = calendar.startOfDay(for: start)
    let componentsStart = calendar.dateComponents([.hour, .minute], from: startOfDay, to: start)
    let startMinutes = CGFloat((componentsStart.hour ?? 0) * 60 + (componentsStart.minute ?? 0))
    let componentsEnd = calendar.dateComponents([.hour, .minute], from: startOfDay, to: end)
    let endMinutes = CGFloat((componentsEnd.hour ?? 0) * 60 + (componentsEnd.minute ?? 0))

    let clampedStart = max(startMinutes, minHour * 60)
    let clampedEnd = min(endMinutes, 23 * 60)

    let duration = clampedEnd - clampedStart
    guard duration > 0 else { return nil }

    let minuteHeight = hourHeight / 60.0
    let topOffset = (clampedStart - minHour * 60) * minuteHeight
    let height = duration * minuteHeight

    return PositionedTraining(
        training: training,
        topOffset: topOffset,
        height: height,
        column: column,
        totalColumns: totalColumns
    )
}

func makeTrainingOffsetHeight(from training: Training, hourHeight: CGFloat) -> (topOffset: CGFloat, height: CGFloat)? {
    guard let start = training.date, let end = training.endTime else { return nil }
    let calendar = Calendar.current
    let minHour: CGFloat = 6

    let startOfDay = calendar.startOfDay(for: start)
    let componentsStart = calendar.dateComponents([.hour, .minute], from: startOfDay, to: start)
    let startMinutes = CGFloat((componentsStart.hour ?? 0) * 60 + (componentsStart.minute ?? 0))
    let componentsEnd = calendar.dateComponents([.hour, .minute], from: startOfDay, to: end)
    let endMinutes = CGFloat((componentsEnd.hour ?? 0) * 60 + (componentsEnd.minute ?? 0))

    let clampedStart = max(startMinutes, minHour * 60)
    let clampedEnd = min(endMinutes, 23 * 60)

    let duration = clampedEnd - clampedStart
    guard duration > 0 else { return nil }

    let minuteHeight = hourHeight / 60.0
    let topOffset = (clampedStart - minHour * 60) * minuteHeight
    let height = duration * minuteHeight

    return (topOffset, height)
}

struct TrainingTimelineLayer: View {
    let positionedTrainings: [PositionedTraining]
    @Binding var selectedTraining: Training?
    let selectedDate: Date
    let leftBound: CGFloat
    let rightBound: CGFloat
    var onTrainingChanged: (() -> Void)? = nil
    let fixedWidth: CGFloat
    let hourHeight: CGFloat

    @State private var nowOffset: CGFloat? = currentTimeOffset()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private let adjustedLeftBound: CGFloat = 35 + 20
    private let adjustedRightBound: CGFloat = UIScreen.main.bounds.width * 0.75 - 10 + 20

    var body: some View {
        GeometryReader { geometry in
            let _ = print("🔴 leftBound = \(leftBound), rightBound = \(rightBound), ширина: \(rightBound - leftBound)")
            let _ = print("📦 Trainings count = \(positionedTrainings.count)")
            ZStack(alignment: .topLeading) {
                if Calendar.current.isDateInToday(selectedDate),
                   let offset = nowOffset {
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 1)
                        .offset(y: offset - 0.5)
                        .padding(.leading, 50)
                }

                ZStack(alignment: .topLeading) {
                    ForEach(positionedTrainings) { item in
                        DraggableTrainingView(
                            positionedTraining: item,
                            hourHeight: hourHeight,
                            leftBound: leftBound,
                            rightBound: rightBound,
                            onTrainingChanged: {
                                onTrainingChanged?()
                            },
                            fixedWidth: fixedWidth
                        )
                    }
                }
                .frame(width: fixedWidth)
            }
        }
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


