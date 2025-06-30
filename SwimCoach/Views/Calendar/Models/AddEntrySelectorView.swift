////
////  AddEntrySelectorView.swift
////  SwimCoach
////
////  Created by Дмитрий Дудник on 27.06.2025.
////
//
//import SwiftUI
//
//struct AddEntrySelectorView: View {
//    let onEntryCreated: () -> Void
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var showAddEntryView = false
//
//    var body: some View {
//        NavigationStack {
//            List {
//                Button("Создать запись") {
//                    showAddEntryView = true
//                }
//            }
//            .navigationTitle("Новая запись")
//            .sheet(isPresented: $showAddEntryView, onDismiss: {
//                onEntryCreated()
//            }) {
//                AddTrainingView(viewModel: AddTrainingViewModel())
//            }
//        }
//    }
//}
