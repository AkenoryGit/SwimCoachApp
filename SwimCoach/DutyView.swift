//
//  DutyView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

import SwiftUI

struct DutyView: View {
    let positionedDuty: PositionedDuty

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Дежурство")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            if let note = positionedDuty.duty.note {
                Text(note)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(6)
        .background(Color.orange.opacity(0.85))
        .cornerRadius(8)
        .frame(height: positionedDuty.height)
        .offset(y: positionedDuty.topOffset)
    }
}

struct DutyBlockView: View {
    let duty: Duty
    let topOffset: CGFloat
    let height: CGFloat
    let availableWidth: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange.opacity(0.7))
            .frame(width: availableWidth, height: height)
            .overlay(
                VStack(alignment: .leading, spacing: 4) {
                    Text("Дежурство")
                        .font(.caption)
                        .bold()

                    if let note = duty.note, !note.isEmpty {
                        Text(note)
                            .font(.caption2)
                            .lineLimit(2)
                    }

                    if let trainer = duty.trainerName, !trainer.isEmpty {
                        Text("За: \(trainer)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(5)
            )
            .offset(x: UIScreen.main.bounds.width - availableWidth, y: topOffset)
//            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
