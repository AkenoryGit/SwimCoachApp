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

    @StateObject private var coachDetailVM: CoachDetailViewModel
    @ObservedObject var viewModel: PeopleListViewModel
    let coach: CoachData

    init(coach: CoachData, viewModel: PeopleListViewModel) {
        self.coach = coach
        self._coachDetailVM = StateObject(wrappedValue: CoachDetailViewModel(coach: coach))
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(coachDetailVM.fullName).font(.title2)
                    if !coachDetailVM.specialty.isEmpty {
                        Text("Специализация: \(coachDetailVM.specialty)")
                    }
                } header: {
                    Text("Основная информация")
                }
            }
            .navigationTitle("Карточка тренера")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") {
                        coachDetailVM.showingEditForm = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        coachDetailVM.showingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
            .alert("Удалить тренера?", isPresented: $coachDetailVM.showingDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    viewModel.selectedCoachIDs = [coach.id ?? UUID()]
                    viewModel.deleteSelectedOrPermanently()
                    if !viewModel.showingProtectedCoachAlert {
                        dismiss()
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
            .sheet(isPresented: $coachDetailVM.showingEditForm) {
                EditCoachView(coach: coachDetailVM.coach)
            }
        }
    }
}
