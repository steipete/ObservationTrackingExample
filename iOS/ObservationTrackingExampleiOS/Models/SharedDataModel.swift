//
//  SharedDataModel.swift
//  ObservationTrackingExample
//
//  Observable data model for iOS with automatic observation tracking
//

import Foundation
import UIKit
import Observation

/// A shared data model that demonstrates observable properties
@Observable
@MainActor
final class SharedDataModel: Sendable {
    // MARK: - Observable Properties
    
    /// The main text content
    var text: String = "Hello from iOS!"
    
    /// Counter value that can be incremented
    var counter: Int = 0
    
    /// Flag indicating if the model is loading data
    var isLoading: Bool = false
    
    /// List of items for the master view
    var items: [Item] = Item.sampleItems
    
    /// Currently selected item in the detail view
    var selectedItem: Item?
    
    /// Current app theme
    var theme: Theme = .light
    
    // MARK: - Nested Types
    
    /// Represents an item in the list
    struct Item: Identifiable, Equatable {
        let id = UUID()
        var title: String
        var subtitle: String
        var detail: String
        var timestamp: Date = Date()
        
        static var sampleItems: [Item] {
            [
                Item(title: "First Item", 
                     subtitle: "This is the first item", 
                     detail: "Detailed information about the first item goes here."),
                Item(title: "Second Item", 
                     subtitle: "This is the second item", 
                     detail: "Detailed information about the second item goes here."),
                Item(title: "Third Item", 
                     subtitle: "This is the third item", 
                     detail: "Detailed information about the third item goes here."),
                Item(title: "Fourth Item", 
                     subtitle: "This is the fourth item", 
                     detail: "Detailed information about the fourth item goes here."),
                Item(title: "Fifth Item", 
                     subtitle: "This is the fifth item", 
                     detail: "Detailed information about the fifth item goes here.")
            ]
        }
    }
    
    /// Available themes
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
        
        var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .auto: return .unspecified
            }
        }
    }
    
    // MARK: - Methods
    
    /// Increments the counter
    func incrementCounter() {
        counter += 1
    }
    
    /// Resets the counter to zero
    func resetCounter() {
        counter = 0
    }
    
    /// Adds a new item to the list
    func addItem() {
        let newItem = Item(
            title: "Item #\(items.count + 1)",
            subtitle: "Added at \(Date().formatted(date: .omitted, time: .shortened))",
            detail: "This is a newly created item with counter value: \(counter)"
        )
        items.append(newItem)
    }
    
    /// Removes an item at the specified index
    func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        
        // If we're removing the selected item, clear selection
        if let selected = selectedItem, 
           items[index].id == selected.id {
            selectedItem = nil
        }
        
        items.remove(at: index)
    }
    
    /// Simulates loading data
    func loadData() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Update data
        text = "Data loaded at \(Date().formatted())"
        incrementCounter()
        
        isLoading = false
    }
}