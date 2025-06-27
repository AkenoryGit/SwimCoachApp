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
            if filteredItems.isEmpty {
                VStack {
                    Spacer()
                    Text(selectedTab == .clients ? "Нет удалённых клиентов" : "Нет удалённых тренеров")
                        .foregroundColor(.secondary)
                        .font(.title3)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(filteredItems, id: \.0) { (id, name) in
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
                                if selectedTab == .clients {
                                    selectedClient = allClients.first { $0.id == id }
                                } else {
                                    selectedCoach = allCoaches.first { $0.id == id }
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
