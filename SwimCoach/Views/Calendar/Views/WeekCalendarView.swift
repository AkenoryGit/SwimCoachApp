//
//  WeekCalendarView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI

struct WeekCalendarView: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private var weekDates: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(weekDates, id: \.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                VStack {
                    Text(shortDayOfWeek(for: date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(calendar.component(.day, from: date))")
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.blue : (calendar.isDateInToday(date) ? Color.gray.opacity(0.3) : Color.clear))
                        )
                }
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func shortDayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
