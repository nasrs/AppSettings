// Copyright © ICS 2024 from aiPhad.com

import ViewInspector

extension InspectableView {
    func find<T>(_ viewType: T.Type,
                 accessibilityIdentifier: String
    ) throws -> InspectableView<T> where T: BaseViewType {
        return try find(viewType) {
            try $0.accessibilityIdentifier() == accessibilityIdentifier
        }
    }
}
