//
//  EnvironmentValues+AppModel.swift
//  ObservationTrackingExample
//
//  Custom environment value for passing AppModel to SwiftUI views
//

import SwiftUI

private struct AppModelEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppModel? = nil
}

extension EnvironmentValues {
    /// The app model accessed through the environment
    var appModel: AppModel? {
        get { self[AppModelEnvironmentKey.self] }
        set { self[AppModelEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Provides the app model to this view and its descendants
    func appModel(_ model: AppModel?) -> some View {
        environment(\.appModel, model)
    }
}