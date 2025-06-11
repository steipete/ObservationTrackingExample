//
//  AppModel.swift
//  NSObservationTrackingExample
//
//  App-wide model with custom trait for passing observable objects
//

import UIKit
import Observation

/// Custom trait for passing the app model through the trait collection
struct AppModelTrait: UITraitDefinition {
    static let defaultValue: AppModel? = nil
    static let affectsColorAppearance = false
    static let name = "AppModel"
    static let identifier = "com.example.AppModelTrait"
}

extension UITraitCollection {
    /// Convenience property for accessing the app model
    var appModel: AppModel? {
        self[AppModelTrait.self]
    }
}

extension UIMutableTraits {
    /// Convenience property for setting the app model
    var appModel: AppModel? {
        get { self[AppModelTrait.self] }
        set { self[AppModelTrait.self] = newValue }
    }
}

/// Main application model that manages shared state
@Observable
final class AppModel {
    // MARK: - Properties
    
    /// The shared data model
    let sharedData = SharedDataModel()
    
    /// Navigation state
    var isShowingSettings = false
    
    /// Split view preferred display mode
    var preferredDisplayMode: UISplitViewController.DisplayMode = .oneBesideSecondary
    
    /// User preferences
    var preferences = UserPreferences()
    
    // MARK: - Nested Types
    
    /// User preferences that persist across app launches
    struct UserPreferences {
        var showTimestamps = true
        var useCompactLayout = false
        var enableAnimations = true
    }
    
    // MARK: - Initialization
    
    init() {
        print("AppModel initialized with observation tracking enabled: \(UIView.isObservationTrackingEnabled)")
    }
    
    // MARK: - Methods
    
    /// Applies the current theme to the given window
    func applyTheme(to window: UIWindow?) {
        window?.overrideUserInterfaceStyle = sharedData.theme.userInterfaceStyle
    }
    
    /// Toggles between split and compact display modes
    func toggleDisplayMode() {
        switch preferredDisplayMode {
        case .oneBesideSecondary:
            preferredDisplayMode = .secondaryOnly
        case .secondaryOnly:
            preferredDisplayMode = .oneOverSecondary
        default:
            preferredDisplayMode = .oneBesideSecondary
        }
    }
}

// MARK: - UIViewController Extension

extension UIViewController {
    /// Provides the app model to child view controllers through traits
    func provideAppModel(_ model: AppModel, to viewController: UIViewController) {
        viewController.traitOverrides.appModel = model
    }
    
    /// Convenience method to access the app model from the trait collection
    var appModel: AppModel? {
        traitCollection.appModel
    }
}