//
//  TrainingDutyTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 27.06.2025.
//

import SwiftUI

struct TrainingDutyTimelineLayer: View {
    let entries: [PositionedEntry]
    let onUpdate: () -> Void
    var onSelectEntry: ((PositionedEntry) -> Void)? = nil

    let labelWidth: CGFloat = 20  // ширина плашки
    let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(entries) { entry in
                    if entry.type == .training {
                        let extraRightPadding: CGFloat = 25
                        let totalColumns = max(entry.totalColumns, 1)
                        let columnWidth = (geometry.size.width - 70 - spacing * CGFloat(totalColumns - 1) - labelWidth - extraRightPadding) / CGFloat(totalColumns)

                        let blockXOffset = 70 + CGFloat(entry.column) * (columnWidth + spacing) + labelWidth + 8 // сдвигаем вправо на 8 пикселей
                        let labelXOffset = blockXOffset - labelWidth

                        // Вертикальное выравнивание плашки — ровно с блоком
                        let verticalOffsetCorrection: CGFloat = 0

                        if let location = entry.location {
                            LocationLabelView(location: location, trainingType: entry.trainingType, height: entry.height)
                                .frame(width: labelWidth, height: entry.height)
                                .offset(x: labelXOffset, y: entry.yOffset + verticalOffsetCorrection)
                        }

                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: columnWidth, height: entry.height)
                            .clipShape(RightRoundedCornersShape(radius: 8))
                            .overlay(
                                VStack(alignment: .leading, spacing: 4) {
                                    if !entry.clientInfoText.isEmpty {
                                        Text(entry.clientInfoText)
                                            .font(.caption2)
                                            .foregroundColor(.black)
                                    } else {
                                        Text(entry.title)
                                            .font(.caption2)
                                            .bold()
                                            .foregroundColor(.black)
                                    }

                                    Text(timeRangeText(entry: entry))
                                        .font(.caption2)
                                        .foregroundColor(.black)
                                }
                                .padding(6)
                                , alignment: .topLeading
                            )
                            .offset(x: blockXOffset, y: entry.yOffset)
                            .onTapGesture {
                                onSelectEntry?(entry)
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 20, height: entry.height)
                            .offset(x: 5, y: entry.yOffset)
                            .onTapGesture {
                                onSelectEntry?(entry)
                            }
                    }
                }
            }
        }
    }

    private func timeRangeText(entry: PositionedEntry) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: entry.startTime)) — \(formatter.string(from: entry.endTime))"
    }

    private func displayTitle(for entry: PositionedEntry) -> String {
        guard let type = entry.trainingType else { return entry.title }

        switch type {
        case .split:
            return "Сплит"
        case .group:
            return "Группа"
        case .miniGroup:
            return "Мини-группа"
        default:
            return entry.clientNames.first ?? type.rawValue
        }
    }
}

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct RightRoundedCornersShape: Shape {
    var radius: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topRight, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
