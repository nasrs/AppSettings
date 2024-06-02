// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension MockEntries {
    enum ChildPane {
        static let title = "ChildPane Title"
        static let fileName = "file_name"
    }
    
    var childPaneData: Data? {
        """
        {
        "Title": "\(ChildPane.title)",
        "File": "\(ChildPane.fileName)"
        }
        """.data(using: .utf8)
    }
}
