//
//  DutyBlockView..swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 18.06.2025.
//

import SwiftUI

// Эта структура представляет собой блок дежурства, который отображается на временной шкале
struct DutyBlockView: View {
    let duty: Duty // Модель данных для дежурства
    let topOffset: CGFloat // Смещение сверху для позиционирования блока
    let height: CGFloat // Высота блока дежурства
    let availableWidth: CGFloat // Доступная ширина для отображения блока
    var onTap: (() -> Void)? = nil // Замыкание, вызываемое при нажатии на блок

    var body: some View { // Основной контент блока дежурства
        VStack(alignment: .leading, spacing: 4) { // Вертикальный стек для размещения элементов внутри блока
            Text("Дежурство") // Заголовок блока дежурства
                .font(.caption) // Шрифт заголовка
                .bold() // Жирный шрифт для выделения заголовка

            if let note = duty.note, !note.isEmpty { // Проверка наличия заметки и её непустоты
                Text(note) // Заметка дежурства
                    .font(.caption2) // Меньший шрифт для заметки
                    .lineLimit(2) // Ограничение количества строк для заметки
            }

            if let trainer = duty.trainerName, !trainer.isEmpty { // Проверка наличия имени тренера и его непустоты
                Text("За: \(trainer)") // Имя тренера, ответственного за дежурство
                    .font(.caption2) // Меньший шрифт для имени тренера
                    .foregroundColor(.secondary) // Цвет текста для имени тренера - вторичный цвет
            }
        }
        .padding(4) // Отступы вокруг содержимого блока
        .frame(width: availableWidth, height: height) // Установка ширины и высоты блока
        .background(Color.blue.opacity(0.7)) // Фоновый цвет блока с прозрачностью
        .cornerRadius(6) // Скругление углов блока
        .offset(y: topOffset) // Смещение блока по вертикали для позиционирования на временной шкале
        .onTapGesture { // Обработчик нажатия на блок
            onTap?() // Вызов замыкания onTap, если оно задано
        }
    }
}
