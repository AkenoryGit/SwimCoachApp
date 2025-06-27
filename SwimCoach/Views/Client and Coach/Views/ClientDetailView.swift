//
//  ClientDetailView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

struct ClientDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ClientDetailViewModel
    @State private var clientToEdit: Client?

    init(client: Client) {
        _viewModel = StateObject(wrappedValue: ClientDetailViewModel(client: client))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основная информация")) {
                    Text(viewModel.fullName).font(.title2)
                    if let birthDate = viewModel.birthDateFormatted {
                        Text("Дата рождения: \(birthDate)")
                    }
                    if let phone = viewModel.phone {
                        Text("Телефон: \(phone)")
                    }
                }

                if let notes = viewModel.notes, !notes.isEmpty {
                    Section(header: Text("Примечания")) {
                        Text(notes)
                    }
                }

                if !viewModel.balances.isEmpty {
                    Section(header: Text("Оплаченные тренировки")) {
                        ForEach(viewModel.balances, id: \.self) { Text($0) }
                    }
                }

                if !viewModel.relatedClients.isEmpty {
                    Section(header: Text("Родственники")) {
                        ForEach(viewModel.relatedClients, id: \.self) { Text($0) }
                    }
                }
            }
            .navigationTitle("Карточка клиента")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") {
                        clientToEdit = viewModel.client
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        viewModel.showingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
            .alert("Удалить клиента?", isPresented: $viewModel.showingDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    viewModel.deleteClient(context: viewContext, dismiss: { dismiss() })
                }
                Button("Отмена", role: .cancel) {}
            }
            .sheet(item: $clientToEdit, onDismiss: {
                viewModel.reload()
            }) { client in
                EditClientView(viewModel: EditClientViewModel(client: client))
            }
        }
    }
}
