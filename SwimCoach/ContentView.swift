//
//  ContentView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddClientForm = false
    @AppStorage("didAddTestClient") private var didAddTestClient = false
    @State private var showingAddTrainingForm = false
    @State private var selectedDate = Date()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default)
    private var clients: FetchedResults<Client>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(clients) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRowView(client: client)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Клиенты")
                .onAppear {
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddClientForm = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink(destination: DeletedClientsView()) {
                            Label("Удалённые", systemImage: "trash")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink(destination: MainTrainingView()) {
                            Label("Календарь", systemImage: "calendar")
                        }
                    }
                }

            }
            .sheet(isPresented: $showingAddClientForm) {
                AddClientView().environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingAddTrainingForm) {
                AddTrainingView().environment(\.managedObjectContext, viewContext)
            }
        }
    }

}
