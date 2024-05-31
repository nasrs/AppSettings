// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Foundation

extension MockEntries {
    enum ChildPane {
        static let title = "ChildPane Title"
        static let fileName = "file_name"
    }
    
    var childpane: Specifier.ChildPane {
        .init(
            title: ChildPane.title,
            characteristic: .init(fileName: ChildPane.fileName)
        )
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
