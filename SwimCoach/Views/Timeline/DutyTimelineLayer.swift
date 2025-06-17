//
//  DutyTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

import SwiftUI
import CoreData

struct DutyTimelineLayer: View {
    let positionedDuties: [PositionedDuty]
    let hourHeight: CGFloat
    var onDutyTapped: ((Duty) -> Void)? = nil

    var body: some View {
        let _ = print("📦 DutyTimelineLayer отрисовывается. Всего duty: \(positionedDuties.count)")

        ZStack(alignment: .topLeading) {
            Color.clear // Фон прозрачный, чтобы не перекрывать другие слои
            ForEach(positionedDuties) { item in
                DutyBlockView(
                    duty: item.duty,
                    topOffset: item.topOffset,
                    height: item.height,
                    availableWidth: 40,
                    onTap: {
                        onDutyTapped?(item.duty)
                    }
                )
                .offset(y: item.topOffset) // 🔥 ключевой момент
            }
        }
        .frame(height: hourHeight * 18) // ⬅️ высота совпадает со шкалой времени
    }
}

