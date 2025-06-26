//
//  DeletedClientsView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

//import SwiftUI
//
//// Этот enum определяет действия, которые можно выполнить с удалёнными клиентами
//enum ClientActionType: Identifiable {
//    case restore(Client) // восстановление клиента
//    case delete(Client) // полное удаление клиента
//
//    var id: String { // уникальный идентификатор для каждого действия
//        switch self { // определяем идентификатор в зависимости от типа действия
//        case .restore(let client): return "restore-\(client.objectID)" // для восстановления клиента
//        case .delete(let client):  return "delete-\(client.objectID)" // для полного удаления клиента
//        }
//    }
//}
//
//// Этот класс управляет логикой для представления удалённых клиентов
//struct DeletedClientsView: View {
//    @Environment(\.managedObjectContext) private var viewContext // контекст Core Data для работы с данными
//    @StateObject private var viewModel = DeletedClientsViewModel() // модель представления, которая управляет действиями с удалёнными клиентами
//
//    @FetchRequest( // запрос для получения удалённых клиентов из Core Data
//        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)], // сортировка по ФИО
//        predicate: NSPredicate(format: "isDeletedClient == YES"), // фильтр для получения только удалённых клиентов
//        animation: .default) // анимация при обновлении данных
//    private var deletedClients: FetchedResults<Client> // результаты запроса, которые будут отображаться в списке
//
//    var body: some View { // основное тело представления
//        let _ = viewModel.refreshTrigger // триггер для обновления представления при изменении данных
//
//        List { // список для отображения удалённых клиентов
//            ForEach(deletedClients) { client in // перебираем каждого удалённого клиента
//                VStack(alignment: .leading) { // вертикальный стек для отображения информации о клиенте
//                    Text(client.fullName ?? "Без имени").font(.headline) // отображаем ФИО клиента, если оно есть
//                    if let birthDate = client.birthDate { // если есть дата рождения
//                        Text("Дата рождения: \(birthDate.formatted(.dateTime.day().month(.wide).year()))") // форматируем и отображаем дату рождения
//                            .font(.subheadline) // подзаголовок для даты рождения
//                            .foregroundColor(.secondary) // серый цвет для второстепенного текста
//                    }
//                }
//                .padding(.vertical, 4) // отступы для улучшения читаемости
//                .swipeActions(edge: .leading) { // Добавляет свайп-действие слева (если пользователь смахнёт карточку клиента вправо)
//                    Button { // Создаёт кнопку внутри свайп-действия
//                        viewModel.selectedAction = .restore(client) // При нажатии кнопки вызывается действие восстановления клиента (.restore(client)), которое сохраняется в переменную selectedAction у viewModel.
//                    } label: {
//                        Label("Восстановить", systemImage: "arrow.uturn.backward") // Метка кнопки содержит текст “Восстановить” и иконку “стрелка назад”.
//                    }.tint(.blue) // .tint(.blue) окрашивает кнопку в синий цвет, чтобы визуально показать, что действие — безопасное и “восстановительное”.
//                }
//                .swipeActions(edge: .trailing) { // Добавляет свайп-действие справа (если пользователь смахнёт карточку влево).
//                    Button(role: .destructive) { // Кнопка для удаления клиента. У неё роль .destructive, что указывает системе, что это “опасное” действие — например, окраска в красный и предупреждающее поведение.
//                        viewModel.selectedAction = .delete(client) // Устанавливает выбранное действие в viewModel.selectedAction, но уже с типом .delete(client).
//                    } label: {
//                        Label("Удалить", systemImage: "trash") // Метка кнопки содержит текст “Удалить” и иконку “корзина”.
//                    }
//                }
//            }
//        }
//        .alert(item: $viewModel.selectedAction) { action in // отображение алерта при выборе действия
//            switch action { // обработка выбранного действия
//            case .restore(let client): // если выбрано восстановление клиента
//                return Alert( // создаём алерт
//                    title: Text("Восстановить клиента?"), // заголовок алерта
//                    message: Text("Клиент снова появится в основном списке."), // сообщение алерта
//                    primaryButton: .default(Text("Восстановить")) { // кнопка для подтверждения действия
//                        viewModel.restore(client, context: viewContext) // восстанавливаем клиента
//                    },
//                    secondaryButton: .cancel() // кнопка для отмены действия
//                )
//            case .delete(let client): // если выбрано полное удаление клиента
//                return Alert( // создаём алерт
//                    title: Text("Удалить клиента?"), // заголовок алерта
//                    message: Text("Это действие невозможно отменить."), // сообщение алерта
//                    primaryButton: .destructive(Text("Удалить")) { // кнопка для подтверждения удаления
//                        viewModel.permanentlyDelete(client, context: viewContext) // полностью удаляем клиента
//                    },
//                    secondaryButton: .cancel() // кнопка для отмены действия
//                )
//            }
//        }
//    }
//}
