//
//  ClientDetailView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

// Эта структура представляет собой экран с детальной информацией о клиенте.
struct ClientDetailView: View {
    @StateObject private var viewModel: ClientDetailViewModel // Используем StateObject для управления состоянием экрана
    
    @Environment(\.managedObjectContext) private var viewContext // Контекст Core Data для работы с данными клиента
    @Environment(\.dismiss) private var dismiss // Позволяет закрыть текущий экран
    
    init(client: Client) { // Инициализируем ViewModel с переданным клиентом
        _viewModel = StateObject(wrappedValue: ClientDetailViewModel(client: client)) // инициализируем StateObject с ViewModel
    }
    
    var body: some View { // тело представления
        Form { // Используем Form для структурирования информации
            Section(header: Text("Основная информация")) { // Секция с основной информацией о клиенте
                Text(viewModel.fullName).font(.title2) // Отображаем полное имя клиента
                
                if let birthDate = viewModel.birthDateFormatted { // Форматированная дата рождения
                    Text("Дата рождения: \(birthDate)") // Отображаем дату рождения
                }
                
                if let phone = viewModel.phone { // Проверяем наличие номера телефона
                    Text("Телефон: \(phone)") // Отображаем номер телефона
                }
            }
            
            // Если есть примечания, то показываем их в отдельной секции
            if let notes = viewModel.notes, !notes.isEmpty { // Проверяем наличие примечаний
                Section(header: Text("Примечания")) { // Секция с примечаниями
                    Text(notes) // Отображаем примечания клиента
                }
            }
            
            // Если есть оплаченные тренировки, то показываем список типов и количеств
            if !viewModel.balances.isEmpty {
                Section(header: Text("Оплаченные тренировки")) { // Секция с оплачиваемыми тренировками
                    ForEach(viewModel.balances, id: \.self) { Text($0) } // Отображаем каждый тип тренировки и количество
                }
            }
            
            // Если у клиента есть связанные родственники, то отображаем их список
            if !viewModel.relatedClients.isEmpty {
                Section(header: Text("Родственники")) { // Секция с родственниками клиента
                    ForEach(viewModel.relatedClients, id: \.self) { Text($0) } // Отображаем каждого родственника
                }
            }
        }
        
        // Заголовок экрана
        .navigationTitle("Карточка клиента")
        
        // Кнопки управления в навигационной панели и в нижней панели
        .toolbar {
            // Кнопка "Редактировать" в правом верхнем углу
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Редактировать") {
                    viewModel.showingEditForm = true // Показываем форму редактирования клиента
                }
            }
            
            // Кнопка "Удалить" в нижней панели
            ToolbarItem(placement: .bottomBar) {
                Button(role: .destructive) { // При нажатии на кнопку "Удалить" показываем предупреждение
                    viewModel.showingDeleteAlert = true // Показываем предупреждение об удалении клиента
                } label: { // Отображаем иконку корзины
                    Label("Удалить", systemImage: "trash") // Иконка корзины для удаления клиента
                }
            }
        }
        
        // Окно подтверждения удаления клиента
        .alert("Удалить клиента?", isPresented: $viewModel.showingDeleteAlert) {
            Button("Удалить", role: .destructive) { // Если пользователь подтвердил удаление
                // При подтверждении вызываем метод удаления во ViewModel
                viewModel.deleteClient(context: viewContext, dismiss: { dismiss() })
            }
            Button("Отмена", role: .cancel) { } // Если пользователь отменил удаление, ничего не делаем
        }
        
        // Открываем экран редактирования, если пользователь нажал "Редактировать"
        .sheet(isPresented: $viewModel.showingEditForm) {
            EditClientView(client: viewModel.client) // Показываем экран редактирования клиента
        }
    }
}
