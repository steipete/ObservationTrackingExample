import Foundation
import Observation

/// Shared data model that demonstrates Swift's @Observable macro
/// This model is automatically tracked by both SwiftUI and AppKit views
@Observable
@MainActor
final class SharedDataModel: Sendable {
    var message = "Try typing here!"
    var counter = 0
    var isEnabled = true
    var selectedColor = "Blue"
    var sliderValue = 50.0
    
    func incrementCounter() {
        counter += 1
    }
    
    func decrementCounter() {
        counter -= 1
    }
    
    func reset() {
        message = "Try typing here!"
        counter = 0
        isEnabled = true
        selectedColor = "Blue"
        sliderValue = 50.0
    }
}