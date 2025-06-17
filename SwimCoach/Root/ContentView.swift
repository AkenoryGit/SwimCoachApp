//
//  ContentView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

// Главный экран приложения, показывающий список всех клиентов
struct ContentView: View {
    
    // Контекст Core Data — нужен для сохранения и получения данных
    @Environment(\.managedObjectContext) private var viewContext

    // Управляет показом формы добавления клиента
    @State private var showingAddClientForm = false

    // Хранит флаг, был ли уже добавлен тестовый клиент
    @AppStorage("didAddTestClient") private var didAddTestClient = false

    // Управляет показом формы добавления тренировки (в этом экране не используется, но подготовлен)
    @State private var showingAddTrainingForm = false

    // Дата, которая может быть использована, например, в календаре
    @State private var selectedDate = Date()

    // Получает из базы всех клиентов, у которых флаг isDeletedClient == false, то есть они не удалены
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)], // сортировка по ФИО
        predicate: NSPredicate(format: "isDeletedClient == NO"), // фильтр для получения только активных клиентов
        animation: .default) // анимация при изменении данных
    private var clients: FetchedResults<Client> // Полученные клиенты из базы данных

    var body: some View { // Главный контейнер для навигации
        // Навигационный стек — позволяет переходить на другие экраны
        NavigationStack {
            VStack(spacing: 0) { // Используем VStack для вертикального расположения элементов
                // Список клиентов
                List {
                    ForEach(clients) { client in
                        // При нажатии на клиента открывается экран с его деталями
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRowView(client: client)
                        }
                        .padding(.vertical, 4) // Отступы для строк списка
                    }
                }
                .navigationTitle("Клиенты") // Заголовок страницы

                // Когда экран появляется впервые
                .onAppear {
                    // Если клиентов нет и ещё не был добавлен тестовый клиент — добавим его
                    if clients.isEmpty && !didAddTestClient {
                        didAddTestClient = true // Устанавливаем флаг, что тестовый клиент добавлен
                        let newClient = Client(context: viewContext) // Создаём нового клиента в контексте Core Data
                        newClient.id = UUID() // Генерируем уникальный ID для клиента
                        newClient.fullName = "Аристархов Аристарх" // Имя клиента
                        newClient.birthDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 7)) // Дата рождения клиента
                        newClient.notes = "5 лет. ПТ. ББ (тестовый клиент, можно удалить)" // Заметка к клиенту
                        newClient.paidTrainingsCount = 3 // Количество оплаченных тренировок
                        try? viewContext.save() // Сохраняем изменения в базе данных
                    }
                }

                // Панель с кнопками
                .toolbar {
                    // Кнопка добавления клиента (в правом верхнем углу)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddClientForm = true // Показываем форму добавления клиента
                        }) {
                            Image(systemName: "plus")
                        }
                    }

                    // Кнопка перехода к удалённым клиентам (в нижней панели)
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink(destination: DeletedClientsView()) {
                            Label("Удалённые", systemImage: "trash")
                        }
                    }

                    // Кнопка перехода к календарю тренировок (в нижней панели)
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink(destination: MainTrainingView()) {
                            Label("Календарь", systemImage: "calendar")
                        }
                    }
                }
            }

            // Модальное окно добавления нового клиента
            .sheet(isPresented: $showingAddClientForm) { // Показываем форму добавления клиента
                AddClientView().environment(\.managedObjectContext, viewContext) // Передаём контекст Core Data в форму
            }

            // Модальное окно добавления новой тренировки (в этой вьюшке пока не вызывается, но подготовлено)
            .sheet(isPresented: $showingAddTrainingForm) { // Показываем форму добавления тренировки
                AddTrainingView().environment(\.managedObjectContext, viewContext) // Передаём контекст Core Data в форму
            }
        }
    }
}
