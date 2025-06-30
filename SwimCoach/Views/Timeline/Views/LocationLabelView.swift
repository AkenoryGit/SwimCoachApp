//
//  LocationLabelView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 30.06.2025.
//

import SwiftUI

struct LocationLabelView: View {
    let location: TrainingLocation
    let trainingType: TrainingType?
    let height: CGFloat

    var body: some View {
        let (labelText, bgColor): (String, Color)

        if trainingType == .startingTraining {
            labelText = "СПТ"
            bgColor = Color.orange
        } else {
            labelText = location.rawValue
            switch location {
            case .bigPool:
                bgColor = Color.green
            case .smallPool:
                bgColor = Color.pink
            default:
                bgColor = Color.gray
            }
        }

        return ZStack {
            RoundedCornersShape(corners: [.topLeft, .bottomLeft], radius: 6)
                .fill(bgColor)
            Text(labelText)
                .font(.caption2.bold())
                .foregroundColor(.white)
                .rotationEffect(.degrees(-90))
                .lineLimit(1)                      // только одна строка
                .minimumScaleFactor(0.5)           // сжать при необходимости
                .frame(width: 20, alignment: .center)
        }
        .frame(width: 20, height: height)
    }
}
