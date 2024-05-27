// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct SliderSpecifierView: SpecifierSettingsView {
    var id: UUID { viewModel.id }
    var viewModel: Specifier.Slider
    
    private var searchIsActive: Bool
    let minValue: Double
    let maxValue: Double
    
    @State var value: Double
    
    init(viewModel: Specifier.Slider, searchActive: Bool) {
        self.viewModel = viewModel
        self.searchIsActive = searchActive
        _value = State<Double>(initialValue: viewModel.characteristic.storedContent)
        minValue = viewModel.characteristic.minValue
        maxValue = viewModel.characteristic.maxValue
    }
    
    var body: some View {
        VStack {
            Slider(value: $value, in: minValue ... maxValue)
                .accessibilityIdentifier(viewModel.accessibilityIdentifier)
            
            HStack {
                Text("Value: \(value, specifier: "%.1f")")
                Spacer()
            }
            
            SearchingKeyView(searchIsActive: searchIsActive,
                             specifierKey: viewModel.specifierKey,
                             specifierTitle: viewModel.title,
                             specifierPath: viewModel.specifierPath)
        }
        .onChange(of: value) { newValue in
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
