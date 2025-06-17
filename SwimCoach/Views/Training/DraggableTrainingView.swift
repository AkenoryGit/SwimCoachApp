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
    let leftBound: CGFloat
    let rightBound: CGFloat
    var onTrainingChanged: (() -> Void)? = nil
    var fixedWidth: CGFloat

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showEditor = false

    var body: some View {
        let training = positionedTraining.training
        let isDuty = training.type == "Дежурство"
        let totalOffset = positionedTraining.topOffset + dragOffset

        let availableWidth = rightBound - leftBound
        let cardWidth = availableWidth / CGFloat(positionedTraining.totalColumns)
        let xOffset = leftBound + CGFloat(positionedTraining.column) * cardWidth

        Group {
            if isDuty {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.7))
                    .frame(width: cardWidth, height: positionedTraining.height)
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Дежурство")
                                .font(.caption)
                                .bold()

                            if let note = training.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption2)
                                    .lineLimit(2)
                            }
                        }
                        .padding(4)
                    )
            } else {
                TrainingCardView(training: training, width: cardWidth)
            }
        }
        .offset(x: xOffset, y: totalOffset)
        .frame(width: cardWidth, height: positionedTraining.height)

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
                            onTrainingChanged?()
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
                EditTrainingView(
                    training: training,
                    entryType: .constant(isDuty ? .duty : .training),
                    onSave: {
                        onTrainingChanged?()
                    }
                )
            }
//        .frame(maxWidth: .infinity)
    }

    private func shift(_ date: Date?, by pixels: CGFloat) -> Date? {
        guard let date = date else { return nil }
        let minutes = pixels / hourHeight * 60
        return Calendar.current.date(byAdding: .minute, value: Int(minutes), to: date)
    }
}
