//
//  TimelineBackgroundView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import SwiftUI

struct TimelineBackgroundView: View {
    let hourHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(6..<24) { hour in
                HStack(spacing: 0) {
                    Text(String(format: "%02d:00", hour))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 50, alignment: .trailing)
                        .padding(.trailing, 4)

                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)

                    Spacer().frame(width: 10)
                }
                Spacer().frame(height: hourHeight - 1)
            }
        }
        .padding(.leading, 10)
    }
}
