//
//  DutyView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

import SwiftUI

// Эта структура представляет собой представление дежурства в виде карточки с информацией о дежурстве.
struct DutyView: View {
    let positionedDuty: PositionedDuty // Представление дежурства с его позицией и размерами

    var body: some View { // тело представления
        VStack(alignment: .leading, spacing: 2) { // вертикальный стек для размещения элементов
            Text("Дежурство") // заголовок дежурства
                .font(.caption2) // размер шрифта
                .fontWeight(.bold) // жирное начертание шрифта
                .foregroundColor(.white) // цвет текста заголовка

            if let note = positionedDuty.duty.note { // если есть заметка о дежурстве
                Text(note) // текст заметки
                    .font(.caption2) // размер шрифта заметки
                    .foregroundColor(.white.opacity(0.8)) // цвет текста заметки с прозрачностью
            }
        }
        .padding(6) // внутренние отступы вокруг текста
        .background(Color.orange.opacity(0.85)) //  фон карточки с оранжевым цветом и прозрачностью
        .cornerRadius(8) // скругление углов карточки
        .frame(height: positionedDuty.height) // высота карточки равна высоте дежурства
        .offset(y: positionedDuty.topOffset) // смещение карточки по вертикали в соответствии с позицией дежурства
    }
}
