//
//  MainTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI
import CoreData

struct MainTrainingView: View {
    @State private var selectedDate = Date()
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CalendarView(selectedDate: $selectedDate)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 8) {
                    HStack {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.left")
                        }

                        Spacer()

                        Text(dateFormatter.string(from: selectedDate))
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal)

                    ZStack(alignment: .topLeading) {
                        DayTimelineView(selectedDate: $selectedDate)
                        DutyLayerView(selectedDate: $selectedDate)
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddTrainingView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
            .onAppear {
                TrainingUpdateNotifier.shared.updateStatusesIfNeeded(context: viewContext)
            }
        }
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
}
