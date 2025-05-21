//
//  CalendarView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                CalendarMonthView(selectedDate: $selectedDate)
                    .opacity(isExpanded ? 1 : 0)
                    .allowsHitTesting(isExpanded)
                
                CalendarWeekView(selectedDate: $selectedDate)
                    .opacity(isExpanded ? 0 : 1)
                    .allowsHitTesting(!isExpanded)
            }
            .frame(height: isExpanded ? 400 : 80) // задай подходящие значения
            .animation(.easeInOut(duration: 0.3), value: isExpanded)
            .clipped()
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .padding()
            }
            .padding(.horizontal)
            .padding(.top, 0)
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current

    var body: some View {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? Date()
        
        HStack(spacing: 12) {
            ForEach(0..<7, id: \.self) { offset in
                let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
                VStack {
                    Text(shortWeekdayName(for: date))
                        .font(.caption)
                    Text(dayNumber(for: date))
                        .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .regular)
                        .padding(6)
                        .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.2) : .clear)
                        .clipShape(Circle())
                }
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal)
    }

    private func shortWeekdayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}


struct MonthData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
}


struct MonthYearPickerView: View {
    @Binding var currentDate: Date
    @Binding var showPicker: Bool

    let months: [String] = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.standaloneMonthSymbols.map { $0.capitalized }
    }()
    let years = Array(2000...Calendar.current.component(.year, from: Date()) + 5)

    var body: some View {
        VStack(spacing: 0) {
            Text("Выбор месяца и года")
                .font(.headline)
                .padding()

            HStack {
                Picker("Месяц", selection: Binding(
                    get: {
                        Calendar.current.component(.month, from: currentDate) - 1
                    },
                    set: { newMonth in
                        currentDate = updateDate(month: newMonth + 1, year: Calendar.current.component(.year, from: currentDate))
                    }
                )) {
                    ForEach(0..<months.count, id: \.self) { index in
                        Text(months[index]).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)

                Picker("Год", selection: Binding(
                    get: {
                        Calendar.current.component(.year, from: currentDate)
                    },
                    set: { newYear in
                        currentDate = updateDate(month: Calendar.current.component(.month, from: currentDate), year: newYear)
                    }
                )) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
            }

            Button("Готово") {
                showPicker = false
            }
            .padding()
        }
        .frame(height: 300)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding()
    }

    private func updateDate(month: Int, year: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: 1)
        return Calendar.current.date(from: components) ?? Date()
    }
}
