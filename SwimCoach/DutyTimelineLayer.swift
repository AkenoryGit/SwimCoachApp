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
                DutyView(positionedDuty: item)
                    .frame(height: item.height)
                    .offset(y: item.topOffset)
                    .padding(.trailing, 8)
            }
        }
    }
}
