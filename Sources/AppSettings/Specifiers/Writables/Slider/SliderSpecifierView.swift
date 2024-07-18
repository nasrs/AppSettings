// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct SliderSpecifierView: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    
    @StateObject var viewModel: Specifier.Slider
    @State var sliderValue: Double = 0.0
    
    private var searchIsActive: Bool
    let minValue: Double
    let maxValue: Double
    // only used for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    init(viewModel: Specifier.Slider, searchActive: Bool) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.searchIsActive = searchActive
        minValue = viewModel.characteristic.minValue
        maxValue = viewModel.characteristic.maxValue
        _sliderValue = State(initialValue: viewModel.characteristic.storedContent)
    }
    
    var body: some View {
        VStack {
            Slider(value: $sliderValue, in: minValue ... maxValue)
                .accessibilityIdentifier(viewModel.accessibilityIdentifier)
            
            HStack {
                Text("Value: \(sliderValue, specifier: "%.1f")")
                Spacer()
            }
            
            SearchingKeyView(searchIsActive: searchIsActive,
                             specifierKey: viewModel.specifierKey,
                             specifierTitle: viewModel.title,
                             specifierPath: viewModel.specifierPath)
        }
        .onChange(of: sliderValue) { newValue in
            if viewModel.characteristic.storedContent != newValue {
                viewModel.characteristic.storedContent = newValue
            }
        }
        .onAppear { didAppear?(self) }
    }
}

#Preview {
    let container = MockRepositoryStorable()
    let viewModel: Specifier.Slider = .init(characteristic:
        .init(key: "key_string",
              defaultValue: 17.0,
              minValue: 6,
              maxValue: 56,
             container: container)
    )
    
    return Form(content: {
        SliderSpecifierView(viewModel: viewModel, searchActive: true)
    })
}
