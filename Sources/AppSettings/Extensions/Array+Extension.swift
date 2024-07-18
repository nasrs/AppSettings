// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Array where Element == (NSDictionary) {
    func filterGroupEntries() -> [NSDictionary] {
        var filteredEntries = [NSDictionary]()
        
        for dict in self {
            if dict["Type"] as? String == Specifier.Kind.group.rawValue {
                break
            }
            filteredEntries.append(dict)
        }
        
        return filteredEntries
    }
}
