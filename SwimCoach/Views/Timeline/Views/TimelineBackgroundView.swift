//
//  TimelineBackgroundView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import SwiftUI

// Этот файл содержит представление TimelineBackgroundView,
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

                    Spacer()
                }
                .frame(height: hourHeight) // вот ключ: вся строка занимает ровно hourHeight
            }
        }
        .padding(.leading, 10)
    }
}
