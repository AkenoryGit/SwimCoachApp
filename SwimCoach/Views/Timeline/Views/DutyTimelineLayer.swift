//
//  DutyTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

import SwiftUI
import CoreData

// Эта структура представляет duty в виде блока на временной шкале
struct DutyTimelineLayer: View {
    let positionedDuties: [PositionedDuty] // Массив позиционированных дежурств, которые будут отображаться на временной шкале
    let hourHeight: CGFloat // Высота одного часа в пикселях, используется для расчёта высоты блоков дежурств
    var onDutyTapped: ((Duty) -> Void)? = nil // Обработчик нажатия на блок дежурства, если он задан

    var body: some View { // тело представления
        let _ = print("📦 DutyTimelineLayer отрисовывается. Всего duty: \(positionedDuties.count)") // Логирование количества дежурств для отладки

        ZStack(alignment: .topLeading) { // Используем ZStack для наложения блоков дежурств
            Color.clear // Фон прозрачный, чтобы не перекрывать другие слои
            ForEach(positionedDuties) { item in // Перебираем все позиционированные дежурства
                DutyBlockView( // Представление блока дежурства
                    duty: item.duty, // Дежурство, которое нужно отобразить
                    topOffset: item.topOffset, // Смещение сверху для правильного позиционирования
                    height: item.height, // Высота блока, рассчитывается на основе высоты часа
                    availableWidth: 40, // Ширина блока, можно настроить по желанию
                    onTap: { // Обработчик нажатия на блок дежурства
                        onDutyTapped?(item.duty) // Вызываем обработчик, если он задан
                    }
                )
                .offset(y: item.topOffset) // Смещение блока по вертикали для правильного позиционирования на временной шкале
            }
        }
        .frame(height: hourHeight * 18) // Высота слоя равна 18 часам, умноженным на высоту одного часа
    }
}

