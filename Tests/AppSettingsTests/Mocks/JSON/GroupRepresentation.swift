// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension MockEntries {
    enum Group {
        static let title = "Group Title"
        static let footerText = "Some Footer Text"
    }
    
    var groupData: Data? {
        """
        {
            "Title": "\(Group.title)",
            "FooterText": "\(Group.footerText)",
        }
        """.data(using: .utf8)
    }
}
