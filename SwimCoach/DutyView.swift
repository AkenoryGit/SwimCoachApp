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
