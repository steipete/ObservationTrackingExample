//
//  ObservationTrackingExampleiOSTests.swift
//  ObservationTrackingExampleiOSTests
//
//  Created by Peter Steinberger on 2025-12-28.
//

import Observation
import Testing
@testable import ObservationTrackingExampleiOS

@Suite("SharedDataModel (iOS)")
@MainActor
struct SharedDataModeliOSTests {
    @Test
    func defaults() {
        let model = SharedDataModel()
        #expect(model.text == "Hello from iOS!")
        #expect(model.counter == 0)
        #expect(model.isLoading == false)
    }
}
