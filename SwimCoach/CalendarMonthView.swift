//
//  CalendarMonthView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

//
//  CalendarMonthView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

struct CalendarMonthView: View {
    @Binding var selectedDate: Date

    @State private var months: [MonthData]
    @State private var currentIndex: Int
    @State private var showMonthYearPicker = false

    private let calendar = Calendar.current

    private let trainings: [LocalTraining] = [
        LocalTraining(date: Date(), title: "Утренняя тренировка"),
        LocalTraining(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, title: "Вечерняя тренировка"),
        LocalTraining(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, title: "Силовая тренировка")
    ]

    // MARK: - Init

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate

        let now = Date()
        let calendar = Calendar.current

        let monthsGenerated = (-12...12).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: now).map { MonthData(date: $0) }
        }

        self._months = State(initialValue: monthsGenerated)

        let initialIndex = monthsGenerated.firstIndex(where: {
            calendar.isDate($0.date, equalTo: selectedDate.wrappedValue, toGranularity: .month)
        }) ?? 12 // текущий месяц
        self._currentIndex = State(initialValue: initialIndex)
    }

    // MARK: - Computed

    private var currentMonthDate: Date {
        months[safe: currentIndex]?.date ?? Date()
    }

    // MARK: - Body

    var body: some View {
        VStack {
            // Заголовок
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Button(action: {
                    showMonthYearPicker.toggle()
                }) {
                    Text(monthTitle(for: currentMonthDate))
                        .font(.headline)
                }

                Spacer()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.bottom, 5)

            // Календарь
            TabView(selection: $currentIndex) {
                ForEach(months.indices, id: \.self) { index in
                    monthGridView(for: months[index].date)
                        .tag(index)
                        .padding(.horizontal)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
            .clipped()

        }
        .padding(.top, 20)
        .onChange(of: selectedDate) { _, _ in
            scrollToSelectedMonth()
        }
        .sheet(isPresented: $showMonthYearPicker) {
            MonthYearPickerView(
                currentDate: Binding(
                    get: { currentMonthDate },
                    set: { newDate in
                        if let index = months.firstIndex(where: {
                            calendar.isDate($0.date, equalTo: newDate, toGranularity: .month)
                        }) {
                            currentIndex = index
                        }
                    }
                ),
                showPicker: $showMonthYearPicker
            )
        }
        .padding()
    }

    // MARK: - View Builders

    private func monthGridView(for date: Date) -> some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        let days = generateMonthDates(for: date)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdays(), id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(days, id: \.self) { day in
                Text("\(calendar.component(.day, from: day))")
                    .fontWeight(calendar.isDate(day, inSameDayAs: selectedDate) ? .bold : .regular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(6)
                    .background(calendar.isDate(day, inSameDayAs: selectedDate) ? Color.blue.opacity(0.2) : .clear)
                    .clipShape(Circle())
                    .onTapGesture {
                        selectedDate = day
                    }
            }
        }
    }

    // MARK: - Helpers

    private func scrollToSelectedMonth() {
        if let index = months.firstIndex(where: {
            calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .month)
        }) {
            currentIndex = index
        }
    }

    private func changeMonth(by value: Int) {
        let newIndex = currentIndex + value
        if months.indices.contains(newIndex) {
            currentIndex = newIndex
        }
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    private func weekdays() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.shortWeekdaySymbols
    }

    private func generateMonthDates(for baseDate: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: baseDate),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let paddingDays = firstWeekday - calendar.firstWeekday
        let totalDays = range.count + (paddingDays >= 0 ? paddingDays : 7 + paddingDays)

        return (0..<totalDays).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - (paddingDays >= 0 ? paddingDays : 7 + paddingDays), to: startOfMonth)
        }
    }
}
