//
//  PersonRowView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//
// Компонент отображения строки одного клиента или тренера.

import SwiftUI

struct PersonRowView: View {
    /// Имя и фамилия
    let name: String

    /// Выделен ли элемент
    let isSelected: Bool

    /// Активен ли режим множественного выбора
    let isSelectionMode: Bool

    /// Показываем ли удалённых
    let isDeletedList: Bool

    var body: some View {
        HStack {
            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
            }

            Text(name)
                .padding(.vertical, 8)

            Spacer()
        }
        .contentShape(Rectangle()) // Делает строку целиком кликабельной
        .background(isDeletedList ? Color.red.opacity(0.1) : Color.clear)
    }
}
