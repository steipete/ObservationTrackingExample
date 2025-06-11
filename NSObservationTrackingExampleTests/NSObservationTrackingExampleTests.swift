//
//  NSObservationTrackingExampleTests.swift
//  NSObservationTrackingExampleTests
//
//  Created by Peter Steinberger on 10.06.25.
//

import Testing
import Observation
@testable import NSObservationTrackingExample

@Suite("SharedDataModel Tests")
@MainActor
struct SharedDataModelTests {
    let dataModel: SharedDataModel
    
    init() {
        dataModel = SharedDataModel()
    }
    
    @Test("Initial values are set correctly")
    func initialValues() {
        #expect(dataModel.message == "Try typing here!")
        #expect(dataModel.counter == 0)
        #expect(dataModel.isEnabled == true)
        #expect(dataModel.selectedColor == "Blue")
        #expect(dataModel.sliderValue == 50.0)
    }
    
    @Test("Counter increment works")
    func counterIncrement() {
        let initialValue = dataModel.counter
        dataModel.incrementCounter()
        #expect(dataModel.counter == initialValue + 1)
        
        dataModel.incrementCounter()
        dataModel.incrementCounter()
        #expect(dataModel.counter == initialValue + 3)
    }
    
    @Test("Counter decrement works")
    func counterDecrement() {
        dataModel.counter = 5
        dataModel.decrementCounter()
        #expect(dataModel.counter == 4)
        
        dataModel.decrementCounter()
        dataModel.decrementCounter()
        #expect(dataModel.counter == 2)
    }
    
    @Test("Counter can go negative")
    func counterNegative() {
        dataModel.counter = 0
        dataModel.decrementCounter()
        #expect(dataModel.counter == -1)
    }
    
    @Test("Reset restores all values to defaults")
    func resetFunctionality() {
        dataModel.message = "Modified message"
        dataModel.counter = 42
        dataModel.isEnabled = false
        dataModel.selectedColor = "Red"
        dataModel.sliderValue = 75.0
        
        dataModel.reset()
        
        #expect(dataModel.message == "Try typing here!")
        #expect(dataModel.counter == 0)
        #expect(dataModel.isEnabled == true)
        #expect(dataModel.selectedColor == "Blue")
        #expect(dataModel.sliderValue == 50.0)
    }
    
    @Test("Message can be modified")
    func messageModification() {
        dataModel.message = "New message"
        #expect(dataModel.message == "New message")
        
        dataModel.message = ""
        #expect(dataModel.message == "")
        
        dataModel.message = "A very long message with special characters !@#$%^&*()"
        #expect(dataModel.message == "A very long message with special characters !@#$%^&*()")
    }
    
    @Test("Boolean toggle works")
    func booleanToggle() {
        let initialState = dataModel.isEnabled
        dataModel.isEnabled.toggle()
        #expect(dataModel.isEnabled == !initialState)
        
        dataModel.isEnabled.toggle()
        #expect(dataModel.isEnabled == initialState)
    }
    
    @Test("Color selection", arguments: ["Blue", "Red", "Green", "Yellow"])
    func colorSelection(color: String) {
        dataModel.selectedColor = color
        #expect(dataModel.selectedColor == color)
    }
    
    @Test("Slider value boundaries", arguments: [0.0, 50.0, 100.0, 25.5, 99.9])
    func sliderValues(value: Double) {
        dataModel.sliderValue = value
        #expect(dataModel.sliderValue == value)
    }
    
    @Test("Slider value clamping")
    func sliderValueClamping() {
        dataModel.sliderValue = -10.0
        #expect(dataModel.sliderValue == -10.0)
        
        dataModel.sliderValue = 150.0
        #expect(dataModel.sliderValue == 150.0)
    }
}

@Suite("Observable Behavior Tests")
@MainActor
struct ObservableBehaviorTests {
    @Test("Observable notifications are triggered")
    func observableNotifications() async throws {
        let dataModel = SharedDataModel()
        
        var messageChanged = false
        withObservationTracking {
            _ = dataModel.message
        } onChange: {
            Task { @MainActor in
                messageChanged = true
            }
        }
        
        dataModel.message = "Changed"
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        #expect(messageChanged == true)
        
        var counterChanged = false
        withObservationTracking {
            _ = dataModel.counter
        } onChange: {
            Task { @MainActor in
                counterChanged = true
            }
        }
        
        dataModel.incrementCounter()
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        #expect(counterChanged == true)
    }
    
    @Test("Multiple property changes in single operation")
    func multiplePropertyChanges() async throws {
        let dataModel = SharedDataModel()
        var changeDetected = false
        
        dataModel.message = "Modified"
        dataModel.counter = 99
        
        withObservationTracking {
            _ = dataModel.message
            _ = dataModel.counter
        } onChange: {
            changeDetected = true
        }
        
        dataModel.reset()
        #expect(changeDetected == true)
        #expect(dataModel.message == "Try typing here!")
        #expect(dataModel.counter == 0)
    }
    
    @Test("Observing specific properties")
    func specificPropertyObservation() async throws {
        let dataModel = SharedDataModel()
        
        var counterTriggered = false
        var messageTriggered = false
        
        withObservationTracking {
            _ = dataModel.counter
        } onChange: {
            Task { @MainActor in
                counterTriggered = true
            }
        }
        
        withObservationTracking {
            _ = dataModel.message
        } onChange: {
            Task { @MainActor in
                messageTriggered = true
            }
        }
        
        dataModel.incrementCounter()
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        #expect(counterTriggered == true)
        #expect(messageTriggered == false)
        
        counterTriggered = false
        dataModel.message = "New message"
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        #expect(counterTriggered == false)
        #expect(messageTriggered == true)
    }
}

@Suite("Thread Safety Tests")
@MainActor
struct ThreadSafetyTests {
    @Test("Concurrent modifications")
    func concurrentModifications() async throws {
        let dataModel = SharedDataModel()
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask { @MainActor in
                    if i % 2 == 0 {
                        dataModel.incrementCounter()
                    } else {
                        dataModel.decrementCounter()
                    }
                }
            }
        }
        
        #expect(dataModel.counter == 0)
    }
    
    @Test("Concurrent property access")
    func concurrentPropertyAccess() async throws {
        let dataModel = SharedDataModel()
        var results: [String] = []
        
        await withTaskGroup(of: String.self) { group in
            for _ in 0..<10 {
                group.addTask { @MainActor in
                    dataModel.message
                }
            }
            
            for await result in group {
                results.append(result)
            }
        }
        
        #expect(results.count == 10)
        #expect(results.allSatisfy { $0 == "Try typing here!" })
    }
}
