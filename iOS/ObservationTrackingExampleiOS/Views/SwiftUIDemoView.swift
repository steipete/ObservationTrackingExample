//
//  SwiftUIDemoView.swift
//  ObservationTrackingExample
//
//  SwiftUI view demonstrating observation tracking
//

import SwiftUI

struct SwiftUIDemoView: View {
    @Bindable var model: SharedDataModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Explanation text
                Text("""
                This SwiftUI view uses the @Observable macro with automatic observation tracking.
                
                Key features:
                • Automatic view updates with @Bindable
                • No need for @Published or ObservableObject
                • Seamless property binding
                • Efficient rendering with fine-grained updates
                
                The counter and text values are synchronized with the UIKit view.
                """)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                
                Divider()
                
                // Text display
                Text(model.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Counter display
                Text("\(model.counter)")
                    .font(.system(size: 48, weight: .semibold, design: .monospaced))
                    .foregroundColor(.green)
                    .padding()
                
                // Buttons
                HStack(spacing: 10) {
                    Button(action: {
                        model.incrementCounter()
                    }) {
                        Text("Increment")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        model.resetCounter()
                    }) {
                        Text("Reset")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                
                // Load data button with progress
                HStack {
                    Button(action: {
                        Task {
                            await model.loadData()
                        }
                    }) {
                        HStack {
                            Text("Load Data")
                                .font(.headline)
                            if model.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.isLoading)
                }
                
                // Theme picker
                Picker("Theme", selection: $model.theme) {
                    ForEach(SharedDataModel.Theme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Items list preview
                GroupBox("Items Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(model.items.prefix(3)) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.headline)
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        
                        if model.items.count > 3 {
                            Text("... and \(model.items.count - 3) more items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemBackground))
        .preferredColorScheme(colorScheme(for: model.theme))
    }
    
    private func colorScheme(for theme: SharedDataModel.Theme) -> ColorScheme? {
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .auto:
            return nil
        }
    }
}