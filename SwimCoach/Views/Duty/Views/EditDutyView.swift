//
//  EditDutyView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 12.06.2025.
//

import SwiftUI

// Эта структура отвечает за редактирование дежурства
struct EditDutyView: View {
    @Environment(\.managedObjectContext) private var viewContext // Контекст Core Data для сохранения изменений
    @Environment(\.dismiss) private var dismiss // Позволяет закрыть модальное окно
    @StateObject private var viewModel: EditDutyViewModel // ViewModel для управления состоянием и логикой

    init(duty: Duty) { // Инициализируем ViewModel с переданным дежурством
        _viewModel = StateObject(wrappedValue: EditDutyViewModel(duty: duty)) // Создаем экземпляр ViewModel с переданным объектом Duty
    }

    var body: some View { // Основной контент экрана
        VStack(spacing: 20) { // Отступы между элементами
            Text("Редактирование дежурства") // Заголовок экрана
                .font(.title2) // Размер шрифта заголовка
                .bold() // Жирный шрифт для заголовка

            TextField("Заметка", text: $viewModel.note) // Поле для ввода заметки
                .textFieldStyle(.roundedBorder) // Стиль поля ввода с закругленными краями

            DatePicker("Начало", selection: $viewModel.startTime, displayedComponents: [.hourAndMinute]) // Поле для выбора времени начала дежурства
            DatePicker("Окончание", selection: $viewModel.endTime, displayedComponents: [.hourAndMinute]) // Поле для выбора времени окончания дежурства

            Picker("Дежурство за", selection: $viewModel.selectedTrainer) { // Пикер для выбора тренера, за которого назначено дежурство
                ForEach(viewModel.allTrainers, id: \.self) { trainer in // Перебираем всех тренеров
                    Text(trainer.fullName).tag(Optional(trainer)) // Отображаем полное имя тренера и связываем его с выбранным значением
                }
            }
            .pickerStyle(MenuPickerStyle()) // Стиль пикера — выпадающее меню

            if let trainer = viewModel.selectedTrainer { // Если тренер выбран, отображаем его полное имя
                Text("Выбран: \(trainer.fullName)") // Отображаем выбранного тренера
                    .font(.caption) // Размер шрифта для выбранного тренера
                    .foregroundColor(.secondary) // Цвет текста для второстепенной информации
            }

            Picker("Статус", selection: $viewModel.selectedStatus) { // Пикер для выбора статуса дежурства
                ForEach(viewModel.allStatuses, id: \.self) { // Перебираем все доступные статусы
                    Text($0).tag($0) // Отображаем статус и связываем его с выбранным значением
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // Устанавливаем стиль отображения Picker'а в виде сегментированного переключателя (как переключатели iOS: "A / B / C")

            Spacer() // Добавляет гибкий пустой промежуток. Он отталкивает следующие элементы вниз, обеспечивая вертикальное распределение контента.

            Button("Сохранить") { // Кнопка "Сохранить" — при нажатии вызывает метод `save` у viewModel
                viewModel.save(context: viewContext) { dismiss() } // Сохраняет изменения в контексте Core Data и закрывает модальное окно
            }
            .buttonStyle(.borderedProminent) // Стиль кнопки — выделенная кнопка с акцентом
            .padding(.top) // Отступ сверху для кнопки

            Button(role: .destructive) { // Кнопка "Удалить дежурство" — при нажатии вызывает метод `delete` у viewModel
                viewModel.delete(context: viewContext) { dismiss() } // Удаляет дежурство из контекста Core Data и закрывает модальное окно
            } label: { // Текст кнопки
                Text("Удалить дежурство").frame(maxWidth: .infinity) // Текст кнопки занимает всю доступную ширину
            }
            .buttonStyle(.bordered) // Стиль кнопки — обычная кнопка с рамкой
            .padding(.top, 10) // Отступ сверху для кнопки удаления
        }
        .padding() // Отступы вокруг всего контента в VStack
    }
}
