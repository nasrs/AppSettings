// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension String {
    static let empty = ""
    static let pipe = "|"
    
    // MARK: Regex wildards
    // containing means in practical terms, "permutation of the string"
    static let contains = "@"
    static let matchOrder = "#"
    static let everything = ".*"
    static let oneOrMore = ".+"
    static let isPermutationSearch = ".+@.+"
    static let isOrderedSearch = ".+#.+"
}

// MARK: - Ordered search

extension String {
    var isOrderedSearch: Bool {
        let regex = try? NSRegularExpression(pattern: .isOrderedSearch)
        return regex?.matchPattern(self) == true
    }
    
    var orderedPattern: String {
        replacingOccurrences(of: String.matchOrder, with: String.everything)
    }
}

// MARK: - Permutation search
    
extension String {
    var isPermutation: Bool {
        let regex = try? NSRegularExpression(pattern: .isPermutationSearch)
        return regex?.matchPattern(self) == true
    }
    
    var permutationPattern: String {
        let componentSeparated = components(separatedBy: String.contains)
        let permuted = permute(items: componentSeparated)
        let pattern = permuted.compactMap {
            $0.compactMap { $0 }.joined(separator: String.everything)
        }.joined(separator: .pipe)
        return pattern
    }
    
    private func permute<C: Collection>(items: C) -> [[C.Iterator.Element]] {
        var scratch = Array(items) // This is a scratch space for Heap's algorithm
        var result: [[C.Iterator.Element]] = [] // This will accumulate our result

        // Heap's algorithm
        func heap(_ n: Int) {
            if n == 1 {
                result.append(scratch)
                return
            }

            for i in 0 ..< n - 1 {
                heap(n - 1)
                let j = (n % 2 == 1) ? 0 : i
                scratch.swapAt(j, n - 1)
            }
            heap(n - 1)
        }

        // Let's get started
        heap(scratch.count)

        // And return the result we built up
        return result
    }
}
