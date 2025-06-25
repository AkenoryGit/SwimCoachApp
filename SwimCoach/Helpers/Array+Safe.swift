//
//  Array+Safe.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

// MARK: - Безопасный доступ к элементу массива по индексу

// Это расширение для массива добавляет безопасный способ доступа к элементам по индексу.
// Оно предотвращает краш, если индекс выходит за пределы допустимого диапазона.
// Вместо ошибки возвращается nil.
//
// Пример использования:
// let values = [1, 2, 3]
// let value = values[safe: 5] // вернёт nil, не вызовет ошибку

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
