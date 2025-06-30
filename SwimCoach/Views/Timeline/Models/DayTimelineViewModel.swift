////
////  DayTimelineViewModel.swift
////  SwimCoach
////
////  Created by Дмитрий Дудник on 24.06.2025.
////
//
//import Foundation
//import CoreData
//import SwiftUI
//import Combine
//
//// Этот файл содержит ViewModel для управления данными на экране дневного расписания.
//class DayTimelineViewModel: ObservableObject {
//    @Published var positionedTrainings: [PositionedTraining] = [] // список тренировок с позиционированием
//    @Published var positionedDuties: [PositionedDuty] = [] // список дежурств с позиционированием
//    @Published var nowOffset: CGFloat? = currentTimeOffset() // смещение текущего времени в пикселях
//
//    private let hourHeight: CGFloat = 60 // высота одного часа в пикселях
//    private var timerCancellable: AnyCancellable? // для хранения подписки на таймер
//
//    init() { // инициализатор
//        // Подписка на обновление текущего времени каждую минуту
//        timerCancellable = Timer.publish(every: 60, on: .main, in: .common) // создаем таймер, который будет срабатывать каждую минуту
//            .autoconnect() // подключаем таймер к основному потоку
//            .sink { _ in // при каждом срабатывании таймера
//                self.nowOffset = currentTimeOffset() // обновляем смещение текущего времени
//            }
//    }
//
//    /// Загрузка и позиционирование тренировок и дежурств на выбранную дату
//    func fetchData(for date: Date, context: NSManagedObjectContext) {
//        let calendar = Calendar.current // используем текущий календарь
//        let startOfDay = calendar.startOfDay(for: date) // получаем начало дня для выбранной даты
//        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return } // получаем конец дня, добавляя один день к началу дня
//
//        let trainingRequest: NSFetchRequest<Training> = Training.fetchRequest() // создаем запрос для получения тренировок
//        trainingRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Training.date, ascending: true)] // сортируем тренировки по дате
//        trainingRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate) // устанавливаем предикат для фильтрации тренировок по дате
//
//        let dutyRequest: NSFetchRequest<Duty> = Duty.fetchRequest() // создаем запрос для получения дежурств
//        dutyRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Duty.startTime, ascending: true)] // сортируем дежурства по времени начала
//        dutyRequest.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", startOfDay as NSDate, endOfDay as NSDate) // устанавливаем предикат для фильтрации дежурств по времени начала
//
//        do { // пытаемся выполнить запросы к базе данных
//            let trainings = try context.fetch(trainingRequest) // получаем массив тренировок из базы данных
//            let duties = try context.fetch(dutyRequest) // получаем массив дежурств из базы данных
//
//            self.positionedTrainings = calculatePositionedTrainings(from: trainings, hourHeight: hourHeight) // позиционируем тренировки
//            self.positionedDuties = makePositionedDuties(from: duties, on: date, hourHeight: hourHeight) // позиционируем дежурства
//
//        } catch { // если произошла ошибка при выполнении запросов
//            print("❌ Ошибка при загрузке данных: \(error.localizedDescription)") // выводим сообщение об ошибке в консоль
//            self.positionedTrainings = [] // очищаем список позиционированных тренировок
//            self.positionedDuties = [] // очищаем список позиционированных дежурств
//        }
//    }
//
//    deinit { // деинициализатор
//        timerCancellable?.cancel() // отменяем подписку на таймер при уничтожении объекта
//    }
//}
