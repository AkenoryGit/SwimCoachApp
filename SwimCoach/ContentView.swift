//
//  ContentView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // Контекст Core Data — "точка входа" к базе
    @Environment(\.managedObjectContext) private var viewContext
    //переменная состояния
    @State private var showingAddClientForm = false
    
    @State private var showingAddTrainingForm = false
    
    @State private var selectedDate = Date()
    
    // Запрос всех клиентов из базы
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"), // фильтр
        animation: .default)
    private var clients: FetchedResults<Client>
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    // Проходимся по всем клиентам из базы и отображаем их
                    ForEach(clients) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRowView(client: client)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Клиенты")
                
                // Этот блок выполняется, когда экран появляется
                .onAppear {
                    // Проверка: если в базе пока нет клиентов, то добавим одного для примера
                    if clients.isEmpty {
                        // Создаём нового клиента в базе, используя текущий контекст (viewContext)
                        let newClient = Client(context: viewContext)
                        
                        // Заполняем поля клиента
                        newClient.id = UUID() // генерируем уникальный ID
                        newClient.fullName = "Аристархов Аристарх" // имя
                        newClient.birthDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 7)) // дата рождения
                        newClient.notes = "5 лет. ПТ. ББ (тестовый клинет, можно удалить)" // примечания
                        newClient.paidTrainingsCount = 3 // количество оплаченных тренировок
                        
                        // Сохраняем изменения в базе данных
                        do {
                            try viewContext.save()
                            print("Тестовый клиент добавлен")
                        } catch {
                            print("Ошибка при сохранении: \(error.localizedDescription)")
                        }
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingAddTrainingForm = true
                        }) {
                            Image(systemName: "calendar.badge.plus")
                        }
                    }
                    //                ToolbarItem(placement: .navigationBarLeading) {
                    //                    NavigationLink(destination: TrainingListView()) {
                    //                        Image(systemName: "list.bullet.rectangle")
                    //                    }
                    //                }
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
                AddClientView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingAddTrainingForm) {
                AddTrainingView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}
