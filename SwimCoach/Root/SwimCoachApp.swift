//
//  SwimCoachApp.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

// Главная точка входа в приложение.
// Атрибут @main указывает, что с этого места начинается выполнение программы.
@main
struct SwimCoachApp: App {
    
    // Это адаптер, который позволяет использовать AppDelegate в SwiftUI-приложении.
    // AppDelegate — это старый способ обработки событий приложения (например, запуск, поворот экрана и т.д.)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Создаём экземпляр PersistenceController, который отвечает за Core Data (базу данных).
    let persistenceController = PersistenceController.shared

    // Основное "тело" приложения — здесь мы описываем, что отображать при запуске
    var body: some Scene {
        // Это главное окно приложения
        WindowGroup {
            // Показываем экран MainTabView, который является корневым View приложения.
            MainTabView()
                // Передаём контекст базы данных внутрь SwiftUI окружения,
                // чтобы внутри всех View можно было использовать @Environment(\.managedObjectContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// Класс AppDelegate используется для управления системными событиями приложения
class AppDelegate: NSObject, UIApplicationDelegate {

    // Статическая переменная для блокировки поворота экрана (по умолчанию только портретный режим)
    static var orientationLock = UIInterfaceOrientationMask.portrait

    // Метод вызывается системой, когда нужно узнать — разрешён ли поворот экрана
    // Мы возвращаем значение из переменной orientationLock (например, .portrait — только вертикально)
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
