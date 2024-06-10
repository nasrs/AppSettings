// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct SliderSpecifierView: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    
    @StateObject var viewModel: Specifier.Slider
    
    private var searchIsActive: Bool
    let minValue: Double
    let maxValue: Double
    
    init(viewModel: Specifier.Slider, searchActive: Bool) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.searchIsActive = searchActive
        minValue = viewModel.characteristic.minValue
        maxValue = viewModel.characteristic.maxValue
    }
    
    var body: some View {
        VStack {
            Slider(value: $viewModel.characteristic.storedContent, in: minValue ... maxValue)
                .accessibilityIdentifier(viewModel.accessibilityIdentifier)
            
            HStack {
                Text("Value: \(viewModel.characteristic.storedContent, specifier: "%.1f")")
                Spacer()
            }
            
            SearchingKeyView(searchIsActive: searchIsActive,
                             specifierKey: viewModel.specifierKey,
                             specifierTitle: viewModel.title,
                             specifierPath: viewModel.specifierPath)
        }
        .onChange(of: viewModel.characteristic.storedContent) { newValue in
            if viewModel.characteristic.storedContent != newValue {
                viewModel.characteristic.storedContent = newValue
            }
        }
    }
}

#Preview {
    let viewModel: Specifier.Slider = .init(characteristic:
        .init(key: "key_string",
              defaultValue: 5,
              minValue: 1,
              maxValue: 32)
    )
    
    return Form(content: {
        SliderSpecifierView(viewModel: viewModel, searchActive: true)
    })
}
