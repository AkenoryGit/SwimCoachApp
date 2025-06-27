//
//  CurrentTimeIndicatorView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import SwiftUI

/// Горизонтальная красная линия с меткой времени
struct CurrentTimeIndicatorView: View {
    let time: Date
    let yOffset: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.red)
                .frame(height: 2)
                .padding(.leading, 50) // сместим чуть правее, чтобы не лезло под текст
                .padding(.trailing, 8) 
            
            Text(formattedTime)
                .font(.caption)
                .padding(4)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(6)
                .padding(.leading, 4)
                .offset(x: +20)// немного отступа от края
        }
        .offset(y: yOffset + 20)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
}
