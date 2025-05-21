//
//  ClientDetailView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

struct ClientDetailView: View {
    let client: Client
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteAlert = false
    @State private var showingEditForm = false

    var body: some View {
        Form {
            Section(header: Text("Основная информация")) {
                Text(client.fullName ?? "Без имени")
                    .font(.title2)

                if let birthDate = client.birthDate {
                    let formatter = Date.FormatStyle.dateTime
                        .locale(Locale(identifier: "ru_RU"))
                        .day()
                        .month(.wide)
                        .year()
                    
                    Text("Дата рождения: \(birthDate.formatted(formatter))")
                }

                if let phone = client.phone {
                    Text("Телефон: \(phone)")
                }
            }

            if let notes = client.notes, !notes.isEmpty {
                Section(header: Text("Примечания")) {
                    Text(notes)
                }
            }

            if let balances = client.balances as? Set<TrainingBalance>, !balances.isEmpty {
                Section(header: Text("Оплаченные тренировки")) {
                    ForEach(TrainingType.allCases) { type in
                        if let balance = balances.first(where: { $0.type == type.rawValue }), balance.count > 0 {
                            Text("\(type.rawValue): \(balance.count)")
                        }
                    }
                }
            }

            if let related = client.relatedClients as? Set<Client>, !related.isEmpty {
                Section(header: Text("Родственники")) {
                    ForEach(Array(related), id: \.self) { relative in
                        Text(relative.fullName ?? "Без имени")
                    }
                }
            }
        }
        
        .navigationTitle("Карточка клиента")
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Редактировать") {
                    showingEditForm = true
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
        }
        .alert("Удалить клиента?", isPresented: $showingDeleteAlert) {
            Button("Удалить", role: .destructive) {
                deleteClient()
            }
            Button("Отмена", role: .cancel) { }
        }
        .sheet(isPresented: $showingEditForm) {
            EditClientView(client: client)
        }
    }
    private func deleteClient() {
        client.isDeletedClient = true // вместо удаления — помечаем как удалённого

        do {
            try viewContext.save()
            dismiss() // закрываем карточку клиента
        } catch {
            print("Ошибка при удалении клиента: \(error.localizedDescription)")
        }
    }
}
