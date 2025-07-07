//
//  PeopleListUIComponents.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI

extension PeopleListView {
    
    // MARK: - Задний план для скрытия клавиатуры
    var backgroundTapView: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                isSearchFocused = false
            }
    }
    
    // MARK: - Переключатель клиентов/тренеров
    var pickerSection: some View {
        Picker("Тип", selection: $viewModel.selectedTab) {
            ForEach(TabType.allCases) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    // MARK: - Строка поиска
    var searchBar: some View {
        HStack {
            TextField("Поиск по имени", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.leading)
                .focused($isSearchFocused)
            Button {
                // Фильтр по другим полям, если будет нужно
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .imageScale(.large)
                    .padding(.trailing)
            }
        }
    }
    
    // MARK: - Кнопка переключения удалённых
    var showDeletedButton: some View {
        Button(showDeletedPeople ? "Скрыть удалённые" : "Показать удалённые") {
            showDeletedPeople.toggle()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    // MARK: - Панель удаления/отмены
    var selectionToolbar: some View {
        HStack {
            if showDeletedPeople {
                Button("Восстановить") {
                    restoreSelected()
                }
                .foregroundColor(.blue)
                .padding()
                
                Button("Удалить навсегда") {
                    showDeleteAlert = true
                }
                .foregroundColor(.red)
                .padding()
            } else {
                Button("Удалить") {
                    showDeleteAlert = true
                }
                .foregroundColor(.red)
                .padding()
            }
            
            Spacer()
            
            Button("Отмена") {
                clearSelection()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
