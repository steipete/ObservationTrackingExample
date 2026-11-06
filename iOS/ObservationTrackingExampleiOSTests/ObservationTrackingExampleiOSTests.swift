//
//  ObservationTrackingExampleiOSTests.swift
//  ObservationTrackingExampleiOSTests
//
//  Created by Peter Steinberger on 2025-12-28.
//

import Observation
import Testing
import UIKit
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

@Suite("Root separator", .serialized)
@MainActor
struct RootSeparatorTests {
    @Test
    func oneAxisAtATimeAndPinnedToTheStack() {
        let root = RootViewController()
        root.traitOverrides.horizontalSizeClass = .regular
        root.traitOverrides.verticalSizeClass = .regular
        root.loadViewIfNeeded()
        root.updateLayoutForTraitCollection()

        let separator = root.view.subviews.first { !($0 is UIStackView) }!
        let stack = root.view.subviews.first { $0 is UIStackView }!
        var active = constraints(touching: separator, in: root.view).filter(\.isActive)
        #expect(active.contains { $0.firstAttribute == .width && $0.constant == 1 })
        #expect(!active.contains { $0.firstAttribute == .height })
        #expect(active.allSatisfy { otherView($0, besides: separator) !== root.view })
        #expect(active.allSatisfy { otherView($0, besides: separator) === stack || otherView($0, besides: separator) == nil })

        root.traitOverrides.horizontalSizeClass = .compact
        root.updateLayoutForTraitCollection()
        active = constraints(touching: separator, in: root.view).filter(\.isActive)
        #expect(active.contains { $0.firstAttribute == .height && $0.constant == 1 })
        #expect(!active.contains { $0.firstAttribute == .width })
        #expect(active.allSatisfy { otherView($0, besides: separator) !== root.view })
        #expect(active.count == 4)
    }
}

private func constraints(touching view: UIView, in root: UIView) -> [NSLayoutConstraint] {
    (root.constraints + view.constraints).filter {
        ($0.firstItem as? UIView) == view || ($0.secondItem as? UIView) == view
    }
}

private func otherView(_ constraint: NSLayoutConstraint, besides view: UIView) -> UIView? {
    if (constraint.firstItem as? UIView) == view {
        return constraint.secondItem as? UIView
    }
    return constraint.firstItem as? UIView
}
