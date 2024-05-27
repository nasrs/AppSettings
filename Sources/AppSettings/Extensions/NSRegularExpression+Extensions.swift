// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension NSRegularExpression {
    convenience init?(_ pattern: String) {
        do {
            let patternInUse: String
            if pattern.isPermutation {
                patternInUse = pattern.permutationPattern
            } else if pattern.isOrderedSearch {
                patternInUse = pattern.orderedPattern
            } else {
                patternInUse = pattern
            }
            try self.init(pattern: patternInUse)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).\nError: \(error.localizedDescription)")
            return nil
        }
    }
    
    func matchPattern(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, range: range) != nil
    }
}
