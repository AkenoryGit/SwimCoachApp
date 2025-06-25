//
//  DutyCardView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import SwiftUI

// MARK: - Карточка дежурства на таймлайне

struct DutyCardView: View {

    /// Объект тренировки (используется как дежурство)
    let training: Training

    /// Ширина карточки
    let width: CGFloat

    /// Высота карточки (зависит от длительности дежурства)
    let height: CGFloat

    // MARK: - UI

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange.opacity(0.7))
            .frame(width: width, height: height)
            .overlay(
                VStack(alignment: .leading, spacing: 4) {
                    // Заголовок "Дежурство"
                    Text("Дежурство")
                        .font(.caption)
                        .bold()

                    // Отображение заметки, если она есть
                    if let note = training.note, !note.isEmpty {
                        Text(note)
                            .font(.caption2)
                            .lineLimit(2)
                    }
                }
                .padding(4),
                alignment: .topLeading
            )
    }
} 
