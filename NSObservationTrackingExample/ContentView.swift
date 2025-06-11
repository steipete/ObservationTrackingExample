//
//  ContentView.swift
//  NSObservationTrackingExample
//
//  Created by Peter Steinberger on 10.06.25.
//

import SwiftUI

struct ContentView: View {
    let appState: AppState
    @Bindable var dataModel: SharedDataModel
    @State private var showExplanation = true
    
    init(appState: AppState) {
        self.appState = appState
        self.dataModel = appState.dataModel
    }
    
    func openAppKitWindow() {
        appState.openAppKitWindow()
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "swift")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                        Text("SwiftUI Window")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Text("This window uses SwiftUI's declarative syntax")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showExplanation.toggle() }) {
                        Label(
                            showExplanation ? "Hide Explanation" : "Show Explanation",
                            systemImage: showExplanation ? "chevron.up.circle.fill" : "chevron.down.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
                
                if showExplanation {
                    ExplanationView()
                        .padding()
                        .transition(.asymmetric(
                            insertion: .push(from: .top).combined(with: .opacity),
                            removal: .push(from: .bottom).combined(with: .opacity)
                        ))
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Interactive Controls
                        GroupBox {
                            VStack(alignment: .leading, spacing: 16) {
                                Label("Text Input", systemImage: "text.cursor")
                                    .font(.headline)
                                TextField("Type here and watch it appear in AppKit window...", text: $dataModel.message)
                                    .textFieldStyle(.roundedBorder)
                                Text("Current: \"\(dataModel.message)\"")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        GroupBox {
                            VStack(spacing: 16) {
                                Label("Counter Control", systemImage: "number.circle")
                                    .font(.headline)
                                HStack(spacing: 20) {
                                    Button(action: { dataModel.decrementCounter() }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title)
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(.red)
                                    
                                    Text("\(dataModel.counter)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .frame(minWidth: 80)
                                        .padding(.horizontal)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                    
                                    Button(action: { dataModel.incrementCounter() }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title)
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        GroupBox {
                            VStack(alignment: .leading, spacing: 16) {
                                Label("Interactive Controls", systemImage: "slider.horizontal.3")
                                    .font(.headline)
                                
                                HStack {
                                    Image(systemName: dataModel.isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                                        .foregroundColor(dataModel.isEnabled ? .green : .red)
                                    Toggle("Feature Enabled", isOn: $dataModel.isEnabled)
                                        .toggleStyle(.switch)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Theme Color", systemImage: "paintpalette")
                                    Picker("", selection: $dataModel.selectedColor) {
                                        Label("Blue", systemImage: "circle.fill")
                                            .foregroundColor(.blue)
                                            .tag("Blue")
                                        Label("Red", systemImage: "circle.fill")
                                            .foregroundColor(.red)
                                            .tag("Red")
                                        Label("Green", systemImage: "circle.fill")
                                            .foregroundColor(.green)
                                            .tag("Green")
                                        Label("Yellow", systemImage: "circle.fill")
                                            .foregroundColor(.yellow)
                                            .tag("Yellow")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Label("Value", systemImage: "slider.horizontal.3")
                                        Spacer()
                                        Text("\(Int(dataModel.sliderValue))%")
                                            .font(.system(.body, design: .monospaced))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(6)
                                    }
                                    Slider(value: $dataModel.sliderValue, in: 0...100)
                                        .accentColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: { dataModel.reset() }) {
                                Label("Reset All Values", systemImage: "arrow.counterclockwise.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                            Button(action: { openAppKitWindow() }) {
                                Label("Open AppKit Window", systemImage: "macwindow.badge.plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                    }
                    .padding()
                }
                
                // Footer
                HStack {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .foregroundColor(.blue)
                    Text("Changes sync automatically with AppKit window")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            }
        }
        .frame(minWidth: 500, minHeight: 700)
    }
}

struct ExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is @Observable?")
                .font(.headline)
            
            Text("Swift's @Observable is a macro that makes your data models automatically notify SwiftUI and AppKit when properties change. No more manual notifications!")
                .font(.callout)
            
            Text("How it works:")
                .font(.headline)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("SwiftUI tracks which properties your views read", systemImage: "1.circle.fill")
                Label("When those properties change, views update automatically", systemImage: "2.circle.fill")
                Label("AppKit can now do the same with NSObservationTrackingEnabled", systemImage: "3.circle.fill")
            }
            .font(.callout)
            
            Text("Try changing any value below and watch both windows update instantly!")
                .font(.callout)
                .italic()
                .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView(appState: AppState())
}
