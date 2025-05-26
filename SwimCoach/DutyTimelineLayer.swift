//
//  DutyTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

import SwiftUI

struct DutyTimelineLayer: View {
    let positionedDuties: [PositionedDuty]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(positionedDuties) { item in
                DutyBlockView(
                    duty: item.duty,
                    topOffset: item.topOffset,
                    height: item.height,
                    availableWidth: UIScreen.main.bounds.width * 0.3 // ширина всей колонки
                )
            }
        }
    }
}
