////
////  TrainingListView.swift
////  SwimCoach
////
////  Created by Дмитрий Дудник on 19.05.2025.
////
//
//import SwiftUI
//import CoreData
//
//struct TrainingListView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Training.date, ascending: false)],
//        animation: .default
//    )
//    private var trainings: FetchedResults<Training>
//
//    var body: some View {
//        NavigationStack {
//            GeometryReader { geometry in
//                VStack(spacing: 0) {
//                    List {
//                        ForEach(trainings) { training in
//                            NavigationLink(destination: TrainingDetailView(training: training)) {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(training.date?.formatted(
//                                        .dateTime
//                                            .day()
//                                            .month(.abbreviated)
//                                            .year()
//                                            .hour()
//                                            .minute()
//                                            .locale(Locale(identifier: "ru_RU"))
//                                    ) ?? "Без даты")
//                                    .font(.headline)
//
//                                    Text(training.type ?? "Без типа")
//                                        .foregroundColor(.secondary)
//
//                                    Text("Статус: \(training.status ?? "неизвестно")")
//                                        .font(.caption)
//
//                                    if let clients = training.clients as? Set<Client>, !clients.isEmpty {
//                                        Text("Клиенты: \(clients.map { $0.fullName ?? "Без имени" }.joined(separator: ", "))")
//                                            .font(.caption2)
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                                .padding(.vertical, 4)
//                            }
//                        }
//                    }
//                }
//                .frame(width: geometry.size.width, height: geometry.size.height)
//                .contentShape(Rectangle()) // ВАЖНО: расширяет область для тапов
//                .onTapGesture {
//                    hideKeyboard()
//                }
//            }
//            .navigationTitle("Все тренировки")
//        }
//    }
//
//    private func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
