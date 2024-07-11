// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

public struct SettingsRendererView: View {
    @ObservedObject private var viewModel: SettingsRendererView.ViewModel
    @StateObject private var searchableEntries: SearchableEntries
    @State private var reseting: Bool = false
    // only valid for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    public static func build() -> SettingsRendererView? {
        guard let reader = SettingsBundleReader.shared else {
            assertionFailure("Please run SettingsBundleReader(rootFileName: bundleFileName:) before init SettingsRendererView")
            return nil
        }
        
        return .init(viewModel: .init(reader))
    }
    
    init(viewModel: SettingsRendererView.ViewModel) {
        self.viewModel = viewModel
        _searchableEntries = StateObject(
            wrappedValue: viewModel.searchable
        )
    }
    
    public var body: some View {
        VStack {
            Image(systemName: "minus")
                .resizable()
                .foregroundColor(.black).opacity(0.4)
                .frame(width: 50, height: 6)
                .padding(.top, 16)
            
            NavigationView {
                settingsEntryContent()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Settings renderer")
                                .bold()
                                .font(.largeTitle)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                reseting = true
                                Task {
                                    await viewModel.resetUserDefaults()
                                    reseting = false
                                }
                            }, label: {
                                Text("Reset")
                                    .font(.headline)
                            })
                            .accessibilityIdentifier("reset_navigation_button")
                        }
                    })
            }
            .environmentObject(searchableEntries)
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Insert title or key")
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { didAppear?(self) }
    }
    
    @ViewBuilder
    private func settingsEntryContent() -> some View {
        if viewModel.visibleEntries.isEmpty {
            EmptySearchResultView(reseting: reseting)
        } else {
            Form(content: {
                ForEach(viewModel.visibleEntries, id: \.id) { entryViewModel in
                    SettingsEntryView(viewModel: entryViewModel,
                                      searchIsActive: viewModel.isSearching)
                }
            })
        }
    }
}

#Preview {
    @State var showObject: Bool = true
    let toggle = Specifier.ToggleSwitch(title: "Title",
                                        characteristic: .init(key: "user_defaults_toggle_key",
                                                              defaultValue: true))
    let radio1 = Specifier.Radio(title: "Radio1 Value",
                                 characteristic:
                                 .init(
                                     key: "user_defaults_key1",
                                     defaultValue: "test 2",
                                     titles: [
                                         "test 1",
                                         "test 2",
                                         "test 3",
                                     ],
                                     values: [
                                         "test_1",
                                         "test_2",
                                         "test_3",
                                     ]
                                 )
                 )
    let radio2 = Specifier.Radio(title: "Radio2 Value",
                                 characteristic:
                                 .init(
                                     key: "user_defaults_key2",
                                     defaultValue: "test 2",
                                     titles: [
                                         "test 1",
                                         "test 2",
                                         "test 3",
                                     ],
                                     values: [
                                         "test_1",
                                         "test_2",
                                         "test_3",
                                     ]
                                 )
                 )
    
    let searchableEntries: [any SettingSearchable] = [
        toggle, radio1, radio2
    ]
    
    let entries: [any SettingEntry] = [
        toggle,
        
        Specifier.TextField(title: "Remaining",
                            characteristic: .init(key: "user_defaults_textfield_key",
                                                  defaultValue: "some value")),
        radio1,
        
        Specifier.Group(title: "Title",
                        footerText: "Footer",
                        characteristic: .init(entries: [
                            radio2
                        ])
        )
    ]
    
    let searchVM = SettingsRendererView.ViewModel(
        MockReader(entries: entries,
                   findable: searchableEntries)
    )
    
    return VStack {
        List {
            ForEach(0 ... 20, id: \.self) { idx in
                Text("Content: \(idx)")
            }
        }
    }.onTapGesture {
        showObject.toggle()
    }.sheet(isPresented: $showObject) {
        SettingsRendererView(viewModel: searchVM)
    }
}
