//
//  SystemCalendarView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI
import UIKit

struct SystemCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()

        // Настройка локали и календаря
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Понедельник
        calendarView.calendar = calendar
        calendarView.locale = Locale(identifier: "ru_RU")

        // Выбор даты
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
            selection.setSelected(components, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
        var parent: SystemCalendarView

        init(_ parent: SystemCalendarView) {
            self.parent = parent
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.selectedDate = date
            }
        }
    }
}
