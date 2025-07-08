//
//  MonthCalendarView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 08.07.2025.
//

import SwiftUI

struct MonthCalendarView: View {
    @Binding var selectedDate: Date

    @State private var displayedDate: Date = Date()
    @State private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showMonthYearPicker: String? = nil

    private let calendar = Calendar.current
    private let months = Calendar.current.monthSymbols
    private let years = Array(2000...2100)
    private let monthNames: [String] = [
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
    ]

    var body: some View {
        VStack(spacing: 8) {
            // MARK: - Навигация по месяцам
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        // Кнопка выбора месяца
                        Button(action: {
                            showMonthYearPicker = (showMonthYearPicker == "month") ? nil : "month"
                        }) {
                            Text("\(monthNames[selectedMonthIndex])")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        // Кнопка выбора года
                        Button(action: {
                            showMonthYearPicker = (showMonthYearPicker == "year") ? nil : "year"
                        }) {
                            Text("\(selectedYear)".replacingOccurrences(of: " ", with: ""))
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }

                    if showMonthYearPicker == "month" {
                        Picker("Месяц", selection: $selectedMonthIndex) {
                            ForEach(0..<monthNames.count, id: \.self) { index in
                                Text(monthNames[index]).tag(index)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .clipped()
                        .onChange(of: selectedMonthIndex) { _ in updateDisplayedDate() }

                    } else if showMonthYearPicker == "year" {
                        Picker("Год", selection: $selectedYear) {
                            ForEach(years, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .clipped()
                        .onChange(of: selectedYear) { _ in updateDisplayedDate() }
                    }
                }

                Spacer()

                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // MARK: - Названия дней недели
            let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // MARK: - Сетка дней месяца
                let days = generateDays(for: displayedDate)
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)

                        Text("\(calendar.component(.day, from: date))")
                            .frame(width: 36, height: 36)
                            .background(
                                Circle().fill(
                                    isSelected ? Color.blue.opacity(0.3) :
                                    isToday ? Color.gray.opacity(0.3) :
                                    Color.clear
                                )
                            )
                            .foregroundColor(.primary)
                            .onTapGesture {
                                selectedDate = date
                            }
                    } else {
                        Color.clear.frame(width: 36, height: 36)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Формат месяца и года (не используется напрямую, но можешь оставить)
    private func formattedMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    // MARK: - Создание массива дней для сетки
    private func generateDays(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        let days = range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: firstDay)
        }

        let offset = calendar.component(.weekday, from: days.first ?? Date()) - calendar.firstWeekday
        let prefix: [Date?] = Array<Date?>(repeating: nil, count: offset < 0 ? offset + 7 : offset)
        return prefix + days
    }

    // MARK: - Сдвиг месяца
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: displayedDate) {
            displayedDate = newDate
            selectedMonthIndex = calendar.component(.month, from: newDate) - 1
            selectedYear = calendar.component(.year, from: newDate)
        }
    }

    // MARK: - Обновление даты из выбора
    private func updateDisplayedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonthIndex + 1
        components.day = 1

        if let newDate = calendar.date(from: components) {
            displayedDate = newDate
        }
    }
}
