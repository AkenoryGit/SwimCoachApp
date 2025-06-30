//
//  HideKeyboardModifier.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 30.06.2025.
//

import SwiftUI

//extension View {
//    func dismissKeyboardOnTapAround() -> some View {
//        ZStack {
//            Color.clear
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                }
//            self
//        }
//    }
//}

struct KeyboardDismissWrapper<Content: View>: UIViewControllerRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let controller = UIHostingController(rootView: content)
        controller.view.backgroundColor = .clear

        let tapGesture = UITapGestureRecognizer(
            target: controller.view,
            action: #selector(UIView.endEditing)
        )
        tapGesture.cancelsTouchesInView = false
        controller.view.addGestureRecognizer(tapGesture)

        return controller
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        uiViewController.rootView = content
    }
}

// MARK: - Скрытие клавиатуры
func hideKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil, from: nil, for: nil
    )
}
