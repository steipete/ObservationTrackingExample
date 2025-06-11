//
//  SwiftUIDemoView.swift
//  ObservationTrackingExample
//
//  SwiftUI view demonstrating observation tracking
//

import SwiftUI

struct SwiftUIDemoView: View {
    @Environment(\.appModel) private var appModel: AppModel?
    
    private var model: SharedDataModel? {
        appModel?.sharedData
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Explanation text
                Text("""
                This SwiftUI view demonstrates @Observable with automatic tracking.
                
                Key features:
                • Automatic view updates via @Observable
                • No need for @Published or ObservableObject
                • Model accessed through custom environment value
                • Efficient rendering with fine-grained updates
                
                The model is shared with UIKit through the same trait system!
                """)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                
                Divider()
                
                // Text display
                Text(model?.text ?? "No data")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Counter display
                Text("\(model?.counter ?? 0)")
                    .font(.system(size: 48, weight: .semibold, design: .monospaced))
                    .foregroundColor(.green)
                    .padding()
                
                // Buttons
                HStack(spacing: 10) {
                    Button(action: {
                        model?.incrementCounter()
                    }) {
                        Text("Increment")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        model?.resetCounter()
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
                            await model?.loadData()
                        }
                    }) {
                        HStack {
                            Text("Load Data")
                                .font(.headline)
                            if model?.isLoading == true {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(model?.isLoading == true)
                }
                
                // Theme picker
                if let model = model {
                    Picker("Theme", selection: Binding(
                        get: { model.theme },
                        set: { model.theme = $0 }
                    )) {
                        ForEach(SharedDataModel.Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemBackground))
        .preferredColorScheme(model.map { colorScheme(for: $0.theme) } ?? nil)
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