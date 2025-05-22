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

                AnimatedDaySwitcherView(selectedDate: $selectedDate)
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                TrainingUpdateNotifier.shared.updateStatusesIfNeeded(context: viewContext)
            }
        }
    }
}
