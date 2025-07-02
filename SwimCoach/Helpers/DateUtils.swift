//
//  DateUtils.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 02.07.2025.
//

import SwiftUI

extension Int {
    func yearWord() -> String {
        let number = self % 100
        let lastDigit = self % 10

        if number >= 11 && number <= 14 {
            return "лет"
        }

        switch lastDigit {
        case 1: return "год"
        case 2, 3, 4: return "года"
        default: return "лет"
        }
    }
}
