//
//  DraggableTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI
import CoreData
import UIKit

struct DraggableTrainingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let positionedTraining: PositionedTraining
    let hourHeight: CGFloat

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showEditor = false

    var body: some View {
        let training = positionedTraining.training
        let totalOffset = positionedTraining.topOffset + dragOffset

        TrainingCardView(training: training)
            .frame(height: positionedTraining.height)
            .offset(y: totalOffset)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        }
                        dragOffset = value.translation.height
                        isDragging = true
                    }
                    .onEnded { value in
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred()
                        let minutesDragged = value.translation.height
                        let newStartDate = shift(training.date, by: minutesDragged)
                        let newEndDate = shift(training.endTime, by: minutesDragged)

                        training.date = newStartDate
                        training.endTime = newEndDate

                        do {
                            try viewContext.save()
                        } catch {
                            print("❌ Ошибка при сохранении: \(error)")
                        }

                        dragOffset = 0
                        isDragging = false
                    }
            )
            .onTapGesture {
                if !isDragging {
                    showEditor = true
                }
            }
            .sheet(isPresented: $showEditor) {
                EditTrainingView(training: training)
            }
    }

    private func shift(_ date: Date?, by pixels: CGFloat) -> Date? {
        guard let date = date else { return nil }
        let minutes = pixels / hourHeight * 60
        return Calendar.current.date(byAdding: .minute, value: Int(minutes), to: date)
    }
}
