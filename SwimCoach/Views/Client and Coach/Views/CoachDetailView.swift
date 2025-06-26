//
//  CoachDetailView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI

// Эта структура представляет собой экран с детальной информацией о тренере.
struct CoachDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: CoachDetailViewModel

    init(coach: CoachData) {
        _viewModel = StateObject(wrappedValue: CoachDetailViewModel(coach: coach))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основная информация")) {
                    Text(viewModel.fullName).font(.title2)
                    if !viewModel.specialty.isEmpty {
                        Text("Специализация: \(viewModel.specialty)")
                    }
                }
            }
            .navigationTitle("Карточка тренера")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") {
                        viewModel.showingEditForm = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        viewModel.showingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
            .alert("Удалить тренера?", isPresented: $viewModel.showingDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    viewModel.deleteCoach(context: viewContext, dismiss: { dismiss() })
                }
                Button("Отмена", role: .cancel) {}
            }
            .sheet(isPresented: $viewModel.showingEditForm) {
                EditCoachView(coach: viewModel.coach)
            }
        }
    }
}
