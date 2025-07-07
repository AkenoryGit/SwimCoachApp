//
//  FetchedResultsWrapper.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 02.07.2025.
//

import Foundation

/// Обёртка для передачи массива как RandomAccessCollection (имитация FetchedResults)
struct FetchedResultsWrapper<T>: RandomAccessCollection {
    typealias Element = T
    typealias Index = Int

    private let results: [T]

    init(results: [T]) {
        self.results = results
    }

    var startIndex: Index { results.startIndex }
    var endIndex: Index { results.endIndex }

    subscript(position: Index) -> Element {
        results[position]
    }
}
