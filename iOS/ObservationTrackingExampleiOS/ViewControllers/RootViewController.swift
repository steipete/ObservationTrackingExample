//
//  RootViewController.swift
//  ObservationTrackingExample
//
//  Root view controller that displays UIKit and SwiftUI views side by side
//

import UIKit
import SwiftUI
import Observation

class RootViewController: UIViewController {
    
    // MARK: - Properties
    
    private let model = SharedDataModel()
    private var uikitViewController: UIKitDemoViewController!
    private var swiftUIHostingController: UIHostingController<SwiftUIDemoView>!
    private var themeObservationTracking: ObservationTracking?
    
    // Container views
    private let containerStackView = UIStackView()
    private let uikitContainerView = UIView()
    private let swiftUIContainerView = UIView()
    
    // Labels
    private let uikitLabel = UILabel()
    private let swiftUILabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupChildControllers()
        updateLayoutForTraitCollection()
        
        // Start observing theme changes
        startThemeObservation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.updateLayoutForTraitCollection()
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForTraitCollection()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Observation Tracking Demo"
        
        // Configure stack view
        containerStackView.distribution = .fillEqually
        containerStackView.spacing = 0
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStackView)
        
        // Configure container views
        uikitContainerView.backgroundColor = .systemBackground
        swiftUIContainerView.backgroundColor = .systemBackground
        
        // Add separator line between views
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure labels
        uikitLabel.text = "UIKit View"
        uikitLabel.font = .preferredFont(forTextStyle: .headline)
        uikitLabel.textColor = .systemBlue
        uikitLabel.textAlignment = .center
        uikitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        swiftUILabel.text = "SwiftUI View"
        swiftUILabel.font = .preferredFont(forTextStyle: .headline)
        swiftUILabel.textColor = .systemGreen
        swiftUILabel.textAlignment = .center
        swiftUILabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add labels to container views
        uikitContainerView.addSubview(uikitLabel)
        swiftUIContainerView.addSubview(swiftUILabel)
        
        // Add container views to stack
        containerStackView.addArrangedSubview(uikitContainerView)
        containerStackView.addArrangedSubview(swiftUIContainerView)
        
        // Add separator (positioned manually)
        view.addSubview(separator)
        
        // Setup separator constraints based on orientation
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // UIKit label
            uikitLabel.topAnchor.constraint(equalTo: uikitContainerView.topAnchor, constant: 16),
            uikitLabel.leadingAnchor.constraint(equalTo: uikitContainerView.leadingAnchor, constant: 16),
            uikitLabel.trailingAnchor.constraint(equalTo: uikitContainerView.trailingAnchor, constant: -16),
            
            // SwiftUI label
            swiftUILabel.topAnchor.constraint(equalTo: swiftUIContainerView.topAnchor, constant: 16),
            swiftUILabel.leadingAnchor.constraint(equalTo: swiftUIContainerView.leadingAnchor, constant: 16),
            swiftUILabel.trailingAnchor.constraint(equalTo: swiftUIContainerView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupChildControllers() {
        // Create UIKit view controller
        uikitViewController = UIKitDemoViewController(model: model)
        addChild(uikitViewController)
        uikitContainerView.addSubview(uikitViewController.view)
        uikitViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            uikitViewController.view.topAnchor.constraint(equalTo: uikitLabel.bottomAnchor, constant: 8),
            uikitViewController.view.leadingAnchor.constraint(equalTo: uikitContainerView.leadingAnchor),
            uikitViewController.view.trailingAnchor.constraint(equalTo: uikitContainerView.trailingAnchor),
            uikitViewController.view.bottomAnchor.constraint(equalTo: uikitContainerView.bottomAnchor)
        ])
        
        uikitViewController.didMove(toParent: self)
        
        // Create SwiftUI hosting controller
        let swiftUIView = SwiftUIDemoView(model: model)
        swiftUIHostingController = UIHostingController(rootView: swiftUIView)
        addChild(swiftUIHostingController)
        swiftUIContainerView.addSubview(swiftUIHostingController.view)
        swiftUIHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            swiftUIHostingController.view.topAnchor.constraint(equalTo: swiftUILabel.bottomAnchor, constant: 8),
            swiftUIHostingController.view.leadingAnchor.constraint(equalTo: swiftUIContainerView.leadingAnchor),
            swiftUIHostingController.view.trailingAnchor.constraint(equalTo: swiftUIContainerView.trailingAnchor),
            swiftUIHostingController.view.bottomAnchor.constraint(equalTo: swiftUIContainerView.bottomAnchor)
        ])
        
        swiftUIHostingController.didMove(toParent: self)
    }
    
    private func updateLayoutForTraitCollection() {
        // Update stack view axis based on size class
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            // iPad - side by side
            containerStackView.axis = .horizontal
            
            // Update separator for horizontal layout
            if let separator = view.subviews.first(where: { $0 != containerStackView }) {
                NSLayoutConstraint.deactivate(separator.constraints)
                separator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    separator.widthAnchor.constraint(equalToConstant: 1),
                    separator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    separator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                    separator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
            }
        } else {
            // iPhone - stacked
            containerStackView.axis = .vertical
            
            // Update separator for vertical layout
            if let separator = view.subviews.first(where: { $0 != containerStackView }) {
                NSLayoutConstraint.deactivate(separator.constraints)
                separator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 1),
                    separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    separator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }
        }
    }
    
    // MARK: - Theme Observation
    
    private func startThemeObservation() {
        themeObservationTracking = ObservationTracking { [weak self] in
            self?.applyTheme()
        }
    }
    
    private func applyTheme() {
        ObservationTracking.withTracking {
            // Access the theme property to track it
            view.window?.overrideUserInterfaceStyle = model.theme.userInterfaceStyle
        } onChange: { [weak self] in
            // Re-apply theme when it changes
            DispatchQueue.main.async {
                self?.applyTheme()
            }
        }
    }
    
    deinit {
        themeObservationTracking?.invalidate()
    }
}