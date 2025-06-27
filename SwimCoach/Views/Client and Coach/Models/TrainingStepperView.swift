//
//  TrainingStepperView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import SwiftUI

struct TrainingStepperView: View {
    let type: TrainingType
    @Binding var count: Int

    var body: some View {
        Stepper(value: $count, in: 0...100) {
            Text("\(type.displayName): \(count)")
        }
    }
}
