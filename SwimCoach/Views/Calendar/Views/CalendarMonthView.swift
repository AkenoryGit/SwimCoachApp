//
//  CalendarMonthView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

struct CalendarMonthView: View { // Это главный компонент, отображающий месячный календарь. Он нарисует сетку дней, кнопки навигации и выбор месяца.
    
    @Binding var selectedDate: Date // Это дата, выбранная пользователем. Она будет обновляться при выборе нового дня в календаре.

    @State private var months: [MonthData] // Массив, содержащий данные о месяцах. Каждый элемент представляет собой месяц с его датой и днями.
    @State private var currentIndex: Int // Индекс текущего месяца в массиве `months`. Он будет использоваться для переключения между месяцами.
    @State private var showMonthYearPicker = false // Флаг, указывающий, нужно ли показывать выбор месяца и года. При нажатии на заголовок месяца он будет переключаться.

    private let calendar = Calendar.current // Текущий календарь, используемый для вычислений и форматирования дат.

    init(selectedDate: Binding<Date>) { // Инициализатор, принимающий привязку к выбранной дате.
        self._selectedDate = selectedDate // Привязываем выбранную дату к внутреннему состоянию компонента.

        let now = Date() // Текущая дата, используется для генерации месяцев вокруг нее.
        let calendar = Calendar.current // Используем текущий календарь для вычислений.

        let monthsGenerated = (-12...12).compactMap { offset in // Генерируем месяцы от -12 до +12 относительно текущей даты.
            calendar.date(byAdding: .month, value: offset, to: now).map { MonthData(date: $0) } // Для каждого месяца создаем объект `MonthData`, который содержит дату этого месяца.
        }

        let initialIndex = CalendarUtils.findCurrentMonthIndex(in: monthsGenerated, matching:  selectedDate.wrappedValue, using: calendar) ?? 12 // Находим индекс текущего месяца в сгенерированном массиве. Если не найден, используем 12 (т.е. текущий месяц).

        self._months = State(initialValue: monthsGenerated) // Инициализируем массив месяцев сгенерированными данными.
        self._currentIndex = State(initialValue: initialIndex) // Устанавливаем текущий индекс на найденный индекс текущего месяца.
    }

    private var currentMonthDate: Date { // Геттер для получения даты текущего месяца на основе текущего индекса.
        months[safe: currentIndex]?.date ?? Date() // Возвращаем дату текущего месяца, если индекс в пределах массива, иначе возвращаем текущую дату.
    }

    var body: some View {
        VStack { // Основной вертикальный стек, содержащий все элементы календаря.
            CalendarMonthHeaderView( // Заголовок календаря, отображающий текущий месяц и кнопки навигации.
                currentDate: currentMonthDate, // Передаем текущую дату месяца.
                onBack: { CalendarUtils.changeMonth(&currentIndex, by: -1, in: months) }, // Обработчик для кнопки "Назад", который уменьшает индекс текущего месяца.
                onForward: { CalendarUtils.changeMonth(&currentIndex, by: 1, in: months) }, // Обработчик для кнопки "Вперед", который увеличивает индекс текущего месяца.
                onTitleTap: { showMonthYearPicker.toggle() } // Обработчик для нажатия на заголовок месяца, который переключает вид выбора месяца и года.
            )

            TabView(selection: $currentIndex) { // ТабView для отображения месяцев. Позволяет пользователю пролистывать месяцы горизонтально.
                ForEach(months.indices, id: \.self) { index in // Перебираем индексы массива месяцев.
                    monthGridView(for: months[index].date) // Вызываем функцию для отображения сетки дней месяца для каждого месяца.
                        .tag(index) // Устанавливаем тег для каждого месяца, чтобы TabView мог отслеживать текущий индекс.
                        .padding(.horizontal) // Добавляем горизонтальные отступы для лучшего отображения.
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Устанавливаем стиль TabView как PageTabViewStyle, чтобы отображать месяцы как страницы без индикатора страниц.
            .frame(height: 300) // Устанавливаем фиксированную высоту для TabView, чтобы он не занимал слишком много места.
            .clipped() // Обрезаем содержимое TabView, чтобы оно не выходило за пределы установленной высоты.
        }
        .padding(.top, 20) // Добавляем верхний отступ для лучшего отображения заголовка.
        .onChange(of: selectedDate) { _, _ in // Обработчик изменения выбранной даты. При изменении выбранной даты обновляем текущий индекс.
            scrollToSelectedMonth() // Вызываем функцию для прокрутки к выбранному месяцу.
        }
        .sheet(isPresented: $showMonthYearPicker) { // Показываем модальное окно выбора месяца и года при активации флага `showMonthYearPicker`.
            MonthYearPickerView( // Компонент для выбора месяца и года.
                currentDate: Binding( // Создаем привязку к текущей дате месяца.
                    get: { currentMonthDate }, // Геттер для получения текущей даты месяца.
                    set: { newDate in // Сеттер для установки новой даты месяца.
                        if let index = CalendarUtils.findCurrentMonthIndex(in: months, matching: newDate, using: calendar) { // Пытаемся найти индекс месяца, соответствующего новой дате.
                            currentIndex = index // Если найден, обновляем текущий индекс.
                        }
                    }
                ),
                showPicker: $showMonthYearPicker // Передаем привязку к флагу показа выбора месяца и года.
            )
        }
        .padding() // Добавляем отступы вокруг всего компонента для лучшего отображения.
    }

    private func monthGridView(for date: Date) -> some View { // Функция для создания сетки дней месяца, принимающая дату месяца.
        let columns = Array(repeating: GridItem(.flexible()), count: 7) // Создаем массив колонок для сетки, каждая колонка занимает равное пространство (7 дней в неделе).
        let days = CalendarDateGenerator.generateMonthDates(for: date, calendar: calendar) // Генерируем даты для всех дней месяца, используя `CalendarDateGenerator`.

        return LazyVGrid(columns: columns, spacing: 8) { // Создаем ленивую вертикальную сетку для отображения дней месяца.
            ForEach(CalendarUtils.weekdays(using: calendar), id: \.self) { day in // Показываем заголовки дней недели.
                Text(day) // Отображаем название дня недели.
                    .font(.caption) // Устанавливаем шрифт для заголовков дней недели.
                    .foregroundColor(.secondary) // Устанавливаем цвет текста для заголовков дней недели.
            }

            ForEach(days, id: \.self) { day in // Отображаем каждый день месяца с возможностью выбрать его.
                CalendarGridCellView( // Компонент для отображения отдельной ячейки дня в календаре.
                    day: day, // Передаем дату дня.
                    selectedDate: selectedDate, // Передаем выбранную дату, чтобы ячейка могла отобразить выделение.
                    calendar: calendar, // Передаем календарь для вычислений.
                    onSelect: { selectedDate = $0 } // Обработчик выбора дня, который обновляет выбранную дату при нажатии на ячейку.
                )
            }
        }
    }

    private func scrollToSelectedMonth() {    // Прокрутка к нужному месяцу. Используется при изменении даты извне — находит нужный месяц и прокручивает к нему.
        if let index = CalendarUtils.findCurrentMonthIndex(in: months, matching: selectedDate, using: calendar) { // Пытаемся найти индекс месяца, соответствующего выбранной дате.
            currentIndex = index // Если найден, обновляем текущий индекс, чтобы TabView отображал нужный месяц.
        }
    }
}
