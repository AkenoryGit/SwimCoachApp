//
//  DraggableDutyView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.05.2025.
//

import SwiftUI

struct DraggableDutyView: View {
    let duty: Duty
    let topOffset: CGFloat
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange.opacity(0.8))
            .frame(width: 60, height: height)
            .overlay(
                VStack(alignment: .leading, spacing: 4) {
                    Text("Дежурство")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                    if let note = duty.note, !note.isEmpty {
                        Text(note)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }
                .padding(4),
                alignment: .topLeading
            )
            .offset(y: topOffset)
    }
}
