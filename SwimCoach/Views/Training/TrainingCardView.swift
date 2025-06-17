//
//  TrainingCardView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

struct TrainingCardView: View {
    let training: Training
    var width: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                RoundedCorners(tl: 12, bl: 12)
                    .fill(colorForLocation(training.location))

                Text(shortLabel(for: training.location))
                    .font(.caption2)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if let statusEnum = TrainingStatus(rawValue: training.status ?? "") {
                        Circle()
                            .fill(statusEnum.color)
                            .frame(width: 8, height: 8)
                        Text(statusEnum.shortLabel)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    Text(shortType(training.type))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                if let clients = training.clients as? Set<Client>, !clients.isEmpty {
                    Text(clients.map { $0.fullName ?? "Без имени" }
                        .sorted()
                        .joined(separator: ", "))
                        .font(.caption2)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                }
                if let note = training.note, !note.isEmpty {
                    Text(note)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .minimumScaleFactor(0.5)
                }
                Spacer(minLength: 0)
            }
            .padding(4)
            .frame(width: width - 28) // ← вот тут задаём ширину строго
            .background(Color.gray.opacity(0.9))
            .clipShape(RoundedCorners(tr: 12, br: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .frame(width: width) // ← и вся карточка тянется
    }


    private func shortType(_ type: String?) -> String {
        guard let type = type else { return "Без типа" }
        if type.contains("Персональная") { return "ПТ" }
        if type.contains("Мини-группа") { return "МГ" }
        if type.contains("Групповая") { return "ГР" }
        if type.contains("Сплит") { return "СП" }
        return type
    }

    private func colorForLocation(_ location: String?) -> Color {
        switch location {
        case TrainingLocation.bigPool.rawValue: return .green
        case TrainingLocation.smallPool.rawValue: return .pink
        case TrainingLocation.gym.rawValue: return .blue
        default: return .gray
        }
    }

    private func shortLabel(for location: String?) -> String {
        location ?? ""
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


struct RoundedCorners: Shape {
    var tl: CGFloat = 0
    var tr: CGFloat = 0
    var bl: CGFloat = 0
    var br: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr),
                    radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br),
                    radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl),
                    radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl),
                    radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()

        return path
    }
}

extension TrainingStatus {
    var shortLabel: String {
        switch self {
        case .planned: return "План"
        case .completed: return "Проведена"
        case .cancelled: return "Отмена"
        case .cancelledAndPaid: return "Списано"
        }
    }
}
