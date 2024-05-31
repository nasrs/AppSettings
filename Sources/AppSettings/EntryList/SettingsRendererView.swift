// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

public struct SettingsRendererView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var reseting: Bool = false
    
    public static func build() -> SettingsRendererView? {
        guard let reader = SettingsBundleReader.shared else {
            assertionFailure("Please run SettingsBundleReader(rootFileName: bundleFileName:) before init SettingsRendererView")
            return nil
        }
        let searchVM = SearchViewModel(reader.settingsUnwrapped)
        
        return .init(viewModel: searchVM)
    }
    
    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(
            wrappedValue: viewModel
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
                        }
                    })
            }
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Insert title or key")
        }
        .background(Color(.systemGroupedBackground))
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
    
    let entries: [any SettingEntry] = [
        Specifier.ToggleSwitch(title: "Title",
                               characteristic: .init(key: "user_defaults_toggle_key",
                                                     defaultValue: true)),
        
        Specifier.TextField(title: "Remaining",
                            characteristic: .init(key: "user_defaults_textfield_key",
                                                  defaultValue: "some value")),
        Specifier.Radio(title: "Radio Value",
                        characteristic:
                        .init(
                            key: "user_defaults_key",
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
        ),
        
        Specifier.Group(title: "Title",
                        footerText: "Footer",
                        characteristic: .init(entries: [
                            Specifier.Radio(title: "Radio Value",
                                            characteristic:
                                            .init(
                                                key: "user_defaults_key",
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
                            ),
                        ])
        ),
    ]
    
    let searchVM = SearchViewModel(entries)
    
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
