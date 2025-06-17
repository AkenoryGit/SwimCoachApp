//
//  DeletedClientsView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

enum ClientActionType {
    case restore(Client)
    case delete(Client)
}

struct DeletedClientsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedAction: ClientActionType?
    @State private var refreshTrigger = false
    @State private var showAlert = false
    @State private var clientToDelete: Client?
    @State private var clientToRestore: Client?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == YES"),
        animation: .default)
    private var deletedClients: FetchedResults<Client>

    var body: some View {
        let _ = refreshTrigger // триггер ререндеринга

        List {
            ForEach(deletedClients) { client in
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
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        selectedAction = .restore(client)
                    } label: {
                        Label("Восстановить", systemImage: "arrow.uturn.backward")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        selectedAction = .delete(client)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .alert(item: $selectedAction) { action in
            switch action {
            case .restore(let client):
                return Alert(
                    title: Text("Восстановить клиента?"),
                    message: Text("Клиент снова появится в основном списке."),
                    primaryButton: .default(Text("Восстановить")) {
                        restore(client)
                        refreshTrigger.toggle()
                    },
                    secondaryButton: .cancel()
                )

            case .delete(let client):
                return Alert(
                    title: Text("Удалить клиента?"),
                    message: Text("Это действие невозможно отменить."),
                    primaryButton: .destructive(Text("Удалить")) {
                        permanentlyDelete(client)
                        refreshTrigger.toggle()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func restore(_ client: Client) {
        withAnimation {
            client.isDeletedClient = false
            do {
                try viewContext.save()
            } catch {
                print("Ошибка при восстановлении клиента: \(error.localizedDescription)")
            }
        }
    }
    private func permanentlyDelete(_ client: Client) {
        withAnimation {
            viewContext.delete(client)
            do {
                try viewContext.save()
            } catch {
                print("Ошибка при удалении навсегда: \(error.localizedDescription)")
            }
        }
    }
}

extension ClientActionType: Identifiable {
    var id: String {
        switch self {
        case .restore(let client):
            return "restore-\(client.objectID)"
        case .delete(let client):
            return "delete-\(client.objectID)"
        }
    }
}
