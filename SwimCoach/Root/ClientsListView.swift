//
//  ClientsListView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

// MARK: - Главный экран со списком клиентов

struct ClientsListView: View {
    
    // MARK: - Core Data
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - UI-состояния
    @State private var showingAddClientForm = false
    @State private var showingAddTrainingForm = false
    @AppStorage("didAddTestClient") private var didAddTestClient = false
    @State private var selectedDate = Date() // используется в календаре (резерв)

    // MARK: - Запрос клиентов из Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    )
    private var clients: FetchedResults<Client>

    // MARK: - UI
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Список клиентов
                List {
                    ForEach(clients) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRowView(client: client)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Клиенты")
                .onAppear(perform: checkAndAddTestClient)

                // MARK: - Панель инструментов
                .toolbar {
                    // Добавить клиента
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddClientForm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }

                    // Удалённые клиенты
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink(destination: DeletedClientsView()) {
                            Label("Удалённые", systemImage: "trash")
                        }
                    }

                    // Календарь тренировок
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink(destination: ScheduleView()) {
                            Label("Календарь", systemImage: "calendar")
                        }
                    }
                }
            }

            // MARK: - Модальные формы
            .sheet(isPresented: $showingAddClientForm) {
                AddClientView().environment(\.managedObjectContext, viewContext)
            }

            .sheet(isPresented: $showingAddTrainingForm) {
                AddTrainingView().environment(\.managedObjectContext, viewContext)
            }
        }
    }

    // MARK: - Добавление тестового клиента при первом запуске
    private func checkAndAddTestClient() {
        if clients.isEmpty && !didAddTestClient {
            didAddTestClient = true
            let newClient = Client(context: viewContext)
            newClient.id = UUID()
            newClient.fullName = "Аристархов Аристарх"
            newClient.birthDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 7))
            newClient.notes = "5 лет. ПТ. ББ (тестовый клиент, можно удалить)"
            newClient.paidTrainingsCount = 3

            try? viewContext.save()
        }
    }
}
