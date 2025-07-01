//
//  PeopleListView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 25.06.2025.
//

import SwiftUI
import CoreData

/// Главный экран отображения клиентов и тренеров с поддержкой удаления, восстановления и фильтрации
struct PeopleListView: View {
    @Environment(\.managedObjectContext) var viewContext

    // MARK: - UI Состояния
    @State var selectedTab: TabType = .clients
    @State private var showingAddView = false
    @State var selectedClient: Client?
    @State var selectedCoach: CoachData?
    @State var searchText = ""
    @State var isSelectionMode = false
    @State var selectedClientIDs: Set<UUID> = []
    @State var selectedCoachIDs: Set<UUID> = []
    @State var showDeletedPeople = false
    @State var showDeleteAlert = false
    @FocusState var isSearchFocused: Bool

    // MARK: - CoreData
    @FetchRequest(entity: Client.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)])
    var allClients: FetchedResults<Client>

    @FetchRequest(entity: CoachData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CoachData.fullName, ascending: true)])
    var allCoaches: FetchedResults<CoachData>

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Слой, реагирующий на касание для скрытия клавиатуры
                    Color.clear
                        .contentShape(Rectangle()) // захватывает тапы по всей области
                        .onTapGesture {
                            isSearchFocused = false
                            hideKeyboard()
                        }

                    VStack(spacing: 0) {
                        pickerSection
                        searchBar
                        peopleListSection
                        showDeletedButton
                        if isSelectionMode { selectionToolbar }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            isSearchFocused = false
                            hideKeyboard()
                        }
                    )
                }
            }
            .navigationTitle(currentTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSelectionMode ? "Готово" : "Выбрать") {
                        isSelectionMode.toggle()
                        if !isSelectionMode {
                            clearSelection()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAddView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                if selectedTab == .clients {
                    AddClientView()
                } else {
                    AddCoachView()
                }
            }
            .sheet(item: $selectedClient) { ClientDetailView(client: $0) }
            .sheet(item: $selectedCoach) { CoachDetailView(coach: $0) }
            .alert(showDeletedPeople ? "Удалить навсегда?" : "Удалить выбранные записи?", isPresented: $showDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    showDeletedPeople ? deletePermanently() : deleteSelected()
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это действие нельзя отменить.")
            }
        }
    }
}
