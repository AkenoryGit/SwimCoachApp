//
//  NewScheduleView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI
import CoreData

struct NewScheduleView: View {
    @State private var selectedDate: Date = Date()
    @State private var showMonthView = false
    @State private var positionedEntries: [PositionedEntry] = []
    @State private var showingAddSheet = false
    @State private var currentTime = Date()
    @State private var showRecurrenceEditAlert = false
    @State private var recurrenceEditTargetEntry: PositionedEntry? = nil
    @State private var editingEntry: EditingEntryWrapper? = nil
    
    // Для редактирования выбранной записи
    @State private var selectedEntry: PositionedEntry? = nil
    
    let hourHeight: CGFloat = 60
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    ) private var activeClients: FetchedResults<Client>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CoachData.fullName, ascending: true)],
        predicate: NSPredicate(format: "isMarkedDeleted == NO"),
        animation: .default
    ) private var activeTrainers: FetchedResults<CoachData>

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Заголовок и календарь
            VStack(spacing: 8) {
                HStack {
                    Text(formattedSelectedDate)
                        .font(.title3)
                        .bold()
                    Spacer()
                    Button {
                        withAnimation(.easeInOut) {
                            showMonthView.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(showMonthView ? 180 : 0))
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)

                Group {
                    if showMonthView {
                        SystemCalendarView(selectedDate: $selectedDate)
                            .frame(height: 360)
                            .clipped()
                            .transition(.opacity)
                    } else {
                        WeekCalendarView(selectedDate: $selectedDate)
                            .padding(.horizontal)
                            .frame(height: 80)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: showMonthView)
            }
            .padding(.vertical, 10)
            .background(Color.white)

            Divider()

            // MARK: - Временная шкала и блоки
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    ZStack(alignment: .topLeading) {
                        TimelineBackgroundView(hourHeight: hourHeight)

                        // 🔴 Красная линия текущего времени
                        if Calendar.current.isDateInToday(selectedDate) {
                            let hour = Calendar.current.component(.hour, from: currentTime)
                            if hour >= 6 && hour < 23 {
                                CurrentTimeIndicatorView(time: currentTime, yOffset: currentTimeYOffset)
                            }
                        }

                        TrainingDutyTimelineLayer(
                            entries: positionedEntries,
                            onUpdate: updateEntries,
                            onSelectEntry: handleEntrySelection
                        )
                    }
                    .frame(height: 18 * hourHeight)
                    .ignoresSafeArea(.container, edges: .bottom)
                }
                .onAppear {
                    let currentHour = Calendar.current.component(.hour, from: selectedDate)
                    withAnimation {
                        proxy.scrollTo(currentHour, anchor: .top)
                    }
                    updateEntries()

                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        currentTime = Date()
                    }
                }
            }
        }
        .onChange(of: selectedDate) {
            updateEntries()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Расписание")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        // Лист для добавления новой записи
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                EntryView(viewModel: EntryViewModel(category: .training, initialDate: selectedDate),
                          activeClients: activeClients,
                          activeTrainers: activeTrainers,
                          onSave: {
                              updateEntries()
                              showingAddSheet = false
                          })
            }
        }
        // Лист для редактирования выбранной записи
        .sheet(item: $editingEntry) { wrapper in
            NavigationStack {
                editingEntrySheetView(wrapper: wrapper)
            }
        }
        .alert("Редактировать повторяющуюся запись", isPresented: $showRecurrenceEditAlert) {
            Button("Только эту", role: .cancel) {
                openEditSheet(entry: recurrenceEditTargetEntry, mode: .thisOnly)
            }
            Button("Эту и последующие") {
                openEditSheet(entry: recurrenceEditTargetEntry, mode: .thisAndFollowing)
            }
        } message: {
            Text("Это повторяющаяся запись. Хотите изменить только эту или все последующие?")
        }
        .sheet(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry) {
                selectedEntry = nil
                updateEntries()
            }
        }
    }

    // MARK: - Формат даты
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, EEEE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: selectedDate)
    }

    // MARK: - Смещение текущего времени
    private var currentTimeYOffset: CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        let totalMinutes = (hour - 6) * 60 + minute
        return CGFloat(totalMinutes) * hourHeight / 60
    }

    // MARK: - Загрузка тренировок и дежурств
    private func updateEntries() {
        let context = PersistenceController.shared.container.viewContext
        let dutyRequest: NSFetchRequest<Duty> = Duty.fetchRequest()
        let trainingRequest: NSFetchRequest<Training> = Training.fetchRequest()

        do {
            let duties = try context.fetch(dutyRequest)
            let trainings = try context.fetch(trainingRequest)
            self.positionedEntries = SchedulePositionCalculator.makePositionedEntries(
                date: selectedDate,
                duties: duties,
                trainings: trainings,
                hourHeight: hourHeight
            )
        } catch {
            print("❌ Ошибка загрузки данных: \(error)")
            self.positionedEntries = []
        }
    }
    
    private func openEditSheet(entry: PositionedEntry?, mode: RecurrenceEditMode) {
        guard let entry = entry else { return }
        editingEntry = EditingEntryWrapper(entry: entry, mode: mode)
    }
    
    private func handleEntrySelection(_ entry: PositionedEntry) {
        print("📌 TAP на запись: \(entry.title)")
        selectedEntry = entry
    }
    
    @ViewBuilder
    private func editingEntrySheetView(wrapper: EditingEntryWrapper) -> some View {
        let entry = wrapper.entry
        let mode = wrapper.mode

        if let training = entry.trainingObject {
            EntryView(
                viewModel: EntryViewModel(training: training, recurrenceEditMode: mode),
                activeClients: activeClients,
                activeTrainers: activeTrainers,
                onSave: {
                    updateEntries()
                    editingEntry = nil
                }
            )
        } else if let duty = entry.dutyObject {
            EntryView(
                viewModel: EntryViewModel(duty: duty, recurrenceEditMode: mode),
                activeClients: activeClients,
                activeTrainers: activeTrainers,
                onSave: {
                    updateEntries()
                    editingEntry = nil
                }
            )
        } else {
            Text("Ошибка: не удалось открыть запись")
        }
    }
}

struct EditingEntryWrapper: Identifiable {
    let id = UUID()
    let entry: PositionedEntry
    let mode: RecurrenceEditMode
}


