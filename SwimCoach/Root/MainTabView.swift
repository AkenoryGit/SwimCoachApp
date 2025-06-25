//
//  MainTabView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 25.06.2025.
//

import SwiftUI

/// Главная структура с нижней панелью вкладок (таб-бар)
struct MainTabView: View {

    // MARK: - Перечисление всех вкладок
    enum Tab {
        case clients     // Список клиентов
        case analytics   // Аналитика
        case schedule    // Расписание (главная)
        case templates   // Шаблоны тренировок
        case settings    // Настройки
    }

    // MARK: - Состояние выбранной вкладки
    @State private var selectedTab: Tab = .schedule // Расписание по умолчанию

    var body: some View {
        TabView(selection: $selectedTab) {

            // ВКЛАДКА 1 — КЛИЕНТЫ
            PeopleListView()
                .tabItem {
                    Label("Клиенты", systemImage: "person.3")
                }
                .tag(Tab.clients)

            // ВКЛАДКА 2 — АНАЛИТИКА
            AllTrainingsView()
                .tabItem {
                    Label("Тренировки", systemImage: "doc.text")
                }
                .tag(Tab.analytics)

            // ВКЛАДКА 3 — РАСПИСАНИЕ (ГЛАВНАЯ)
            ScheduleView()
                .tabItem {
                    Label("Расписание", systemImage: "calendar")
                }
                .tag(Tab.schedule)

            // ВКЛАДКА 4 — ШАБЛОНЫ
            Text("Шаблоны тренировок")
                .tabItem {
                    Label("Аналитика", systemImage: "chart.bar")
                }
                .tag(Tab.templates)

            // ВКЛАДКА 5 — НАСТРОЙКИ
            Text("Настройки")
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
    }
}
