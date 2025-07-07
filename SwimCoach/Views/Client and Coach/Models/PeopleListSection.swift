//
//  PeopleListSection.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI

extension PeopleListView {
    
    // MARK: - Секция со списком или сообщением об отсутствии данных
    var peopleListSection: some View {
        Group {
            if viewModel.selectedTab == .clients && filteredClients.isEmpty {
                emptyPlaceholder(text: "Нет удалённых клиентов")
            } else if viewModel.selectedTab == .coaches && filteredCoaches.isEmpty {
                emptyPlaceholder(text: "Нет удалённых тренеров")
            } else {
                List {
                    if viewModel.selectedTab == .clients {
                        ForEach(filteredClients) { client in
                            let id = client.id ?? UUID()
                            let name = client.fullName ?? "Без имени"
                            let ageString = client.age(on: Date()).map { ", \($0) \($0.yearWord())" } ?? ""
                            
                            PersonRowView(
                                name: name + ageString,
                                isSelected: isSelected(id: id),
                                isSelectionMode: isSelectionMode,
                                isDeletedList: showDeletedPeople
                            )
                            .onTapGesture {
                                if isSelectionMode {
                                    toggleSelection(id: id)
                                } else {
                                    selectedClient = client
                                }
                            }
                        }
                    } else {
                        ForEach(filteredCoaches) { coach in
                            let id = coach.id ?? UUID()
                            let name = coach.fullName ?? "Без имени"
                            
                            PersonRowView(
                                name: name,
                                isSelected: isSelected(id: id),
                                isSelectionMode: isSelectionMode,
                                isDeletedList: showDeletedPeople
                            )
                            .onTapGesture {
                                if isSelectionMode {
                                    toggleSelection(id: id)
                                } else {
                                    selectedCoach = coach
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

@ViewBuilder
private func emptyPlaceholder(text: String) -> some View {
    VStack {
        Spacer()
        Text(text)
            .foregroundColor(.secondary)
            .font(.title3)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}
