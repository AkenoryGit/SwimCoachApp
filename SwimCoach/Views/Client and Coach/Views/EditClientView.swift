//
//  EditClientView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

struct EditClientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var viewModel: EditClientViewModel

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Form {
                        Section(header: Text("Основное")) {
                            TextField("ФИО", text: $viewModel.fullName)

                            TextField("Телефон", text: Binding(
                                get: { viewModel.phone },
                                set: { newValue in
                                    let filtered = newValue.filter { "+0123456789".contains($0) }
                                    viewModel.phone = filtered
                                }
                            ))
                            .keyboardType(.phonePad)

                            DatePicker("Дата рождения", selection: $viewModel.birthDate, displayedComponents: .date)
                            TextField("Примечания", text: $viewModel.notes, axis: .vertical)
                        }

                        Section(header: Text("Количество тренировок")) {
                            ForEach(TrainingType.allCases, id: \.self) { type in
                                TrainingStepperView(
                                    type: type,
                                    count: Binding(
                                        get: { viewModel.trainingCounts[type] ?? 0 },
                                        set: { viewModel.trainingCounts[type] = $0 }
                                    )
                                )
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle()) // Важно: захватывает все касания
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle("Редактировать клиента")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        viewModel.saveChanges(context: context)
                        dismiss()
                    }
                    .disabled(viewModel.fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

//    private func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
}
