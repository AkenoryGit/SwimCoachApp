//
//  DayTimelineView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI

struct DayTimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date
    @StateObject private var viewModel = DayTimelineViewModel()

    private let hourHeight: CGFloat = 60

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    TimelineBackgroundView(hourHeight: hourHeight)

                    if Calendar.current.isDateInToday(selectedDate),
                       let offset = viewModel.nowOffset {
                        CurrentTimeIndicatorView(offset: offset, hourHeight: hourHeight)
                    }

                    TrainingTimelineLayer(
                        positionedTrainings: viewModel.positionedTrainings,
                        selectedDate: selectedDate,
                        hourHeight: hourHeight,
                        onTrainingChanged: {
                            viewModel.fetchData(for: selectedDate, context: viewContext)
                        }
                    )

                    DutyTimelineLayer(
                        positionedDuties: viewModel.positionedDuties,
                        hourHeight: hourHeight
                    )
                }
            }
        }
        .onAppear {
            viewModel.fetchData(for: selectedDate, context: viewContext)
        }
        .onChange(of: selectedDate) {
            viewModel.fetchData(for: selectedDate, context: viewContext)
        }
    }
}


