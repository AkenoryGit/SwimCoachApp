//
//  ClientRowView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

struct ClientRowView: View {
    let client: Client

    var body: some View {
        VStack(alignment: .leading) {
            Text(client.fullName ?? "Без имени")
                .font(.headline)

            if let birthDate = client.birthDate {
                let formatter = Date.FormatStyle.dateTime
                    .locale(Locale(identifier: "ru_RU"))
                    .day()
                    .month(.wide)
                    .year()
                
                Text("Дата рождения: \(birthDate.formatted(formatter))")
            }

            if let balances = client.balances as? Set<TrainingBalance>, !balances.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(TrainingType.allCases) { type in
                        if let balance = balances.first(where: { $0.type == type.rawValue }), balance.count > 0 {
                            Text("\(type.rawValue): \(balance.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
