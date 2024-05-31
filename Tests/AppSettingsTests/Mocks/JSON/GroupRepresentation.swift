// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Foundation

extension MockEntries {
    var group: Specifier.Group {
        .init(
            title: "group",
            footerText: "group footer",
            characteristic: .init()
        )
    }
    
    var groupData: Data? {
        """
        {
            "Title": "Group Title",
            "FooterText": "Some Footer Text"",
        }
        """.data(using: .utf8)
    }
}
