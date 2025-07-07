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
    @State private var showingAddView = false
    @State var selectedClient: Client?
    @State var selectedCoach: CoachData?
    @State var searchText = ""
    @State var isSelectionMode = false
    @State var showDeletedPeople = false
    @State var showDeleteAlert = false
    @FocusState var isSearchFocused: Bool
    @StateObject var viewModel: PeopleListViewModel

    // MARK: - CoreData
    @FetchRequest(entity: Client.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)])
    var allClients: FetchedResults<Client>

    @FetchRequest(entity: CoachData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CoachData.fullName, ascending: true)])
    var allCoaches: FetchedResults<CoachData>
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        let clients = try! context.fetch(Client.fetchRequest()) as! [Client]
        let request = CoachData.fetchRequest()
        request.returnsObjectsAsFaults = false // <— это важно!
        let coaches = try! context.fetch(request) as! [CoachData]

        _viewModel = StateObject(wrappedValue: PeopleListViewModel(
            context: context,
            clients: clients,
            coaches: coaches
        ))
    }

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
                if viewModel.selectedTab == .clients {
                    AddClientView()
                } else {
                    AddCoachView()
                }
            }
            .sheet(item: $selectedClient) { ClientDetailView(client: $0) }
            .alert("Невозможно удалить клиента", isPresented: $viewModel.showingProtectedClientAlert) {
                Button("Ок", role: .cancel) { }
            } message: {
                Text("У этого клиента есть тренировки. Сначала удалите или измените эти тренировки.")
            }
            .sheet(item: $selectedCoach) { CoachDetailView(coach: $0, viewModel: viewModel) }
            .alert(showDeletedPeople ? "Удалить навсегда?" : "Удалить выбранные записи?", isPresented: $showDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    viewModel.deleteSelectedOrPermanently()
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это действие нельзя отменить.")
            }
        }
        .alert("Невозможно удалить тренера", isPresented: $viewModel.showingProtectedCoachAlert) {
            Button("Ок", role: .cancel) { }
        } message: {
            Text("Этот тренер прикреплён к дежурствам. Сначала удалите или измените эти дежурства.")
        }
    }
}
