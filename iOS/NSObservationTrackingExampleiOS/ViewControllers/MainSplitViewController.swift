//
//  MainSplitViewController.swift
//  NSObservationTrackingExample
//
//  Main split view controller that manages the master-detail interface
//

import UIKit
import Observation

/// Main split view controller that coordinates master and detail views
final class MainSplitViewController: UISplitViewController {
    
    // MARK: - Properties
    
    /// The app model instance
    private let appModel = AppModel()
    
    /// Master view controller
    private let masterViewController: MasterViewController
    
    /// Detail view controller wrapped in navigation
    private let detailNavigationController: UINavigationController
    
    // MARK: - Initialization
    
    init() {
        // Create view controllers
        masterViewController = MasterViewController()
        let detailViewController = DetailViewController()
        
        // Wrap in navigation controllers
        let masterNavigationController = UINavigationController(rootViewController: masterViewController)
        detailNavigationController = UINavigationController(rootViewController: detailViewController)
        
        // Initialize split view
        super.init(style: .doubleColumn)
        
        // Configure split view
        setViewController(masterNavigationController, for: .primary)
        setViewController(detailNavigationController, for: .secondary)
        
        // Set delegate
        delegate = self
        
        // Configure appearance
        preferredDisplayMode = .oneBesideSecondary
        preferredPrimaryColumnWidthFraction = 0.3
        minimumPrimaryColumnWidth = 300
        maximumPrimaryColumnWidth = 400
        
        // Provide app model to child controllers through traits
        provideAppModel(appModel, to: masterNavigationController)
        provideAppModel(appModel, to: detailNavigationController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Set up observation tracking
        setupObservation()
        
        // Apply initial theme
        if let window = view.window {
            appModel.applyTheme(to: window)
        }
    }
    
    // MARK: - Observation Setup
    
    private func setupObservation() {
        // Observe theme changes
        _ = withObservationTracking {
            appModel.sharedData.theme
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleThemeChange()
            }
        }
        
        // Observe display mode changes
        _ = withObservationTracking {
            appModel.preferredDisplayMode
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleDisplayModeChange()
            }
        }
    }
    
    // MARK: - Change Handlers
    
    private func handleThemeChange() {
        // Apply theme to window
        if let window = view.window {
            appModel.applyTheme(to: window)
        }
        
        // Re-establish observation
        _ = withObservationTracking {
            appModel.sharedData.theme
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleThemeChange()
            }
        }
    }
    
    private func handleDisplayModeChange() {
        // Update split view display mode
        preferredDisplayMode = appModel.preferredDisplayMode
        
        // Re-establish observation
        _ = withObservationTracking {
            appModel.preferredDisplayMode
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleDisplayModeChange()
            }
        }
    }
}

// MARK: - UISplitViewControllerDelegate

extension MainSplitViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, 
                           collapseSecondary secondaryViewController: UIViewController,
                           onto primaryViewController: UIViewController) -> Bool {
        // If no item is selected, show the master view in compact mode
        return appModel.sharedData.selectedItem == nil
    }
    
    func splitViewController(_ svc: UISplitViewController, 
                           topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        // Show master view if no selection
        if appModel.sharedData.selectedItem == nil {
            return .primary
        }
        return proposedTopColumn
    }
}