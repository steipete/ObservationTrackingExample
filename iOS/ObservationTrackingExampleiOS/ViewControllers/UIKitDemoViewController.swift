//
//  UIKitDemoViewController.swift
//  ObservationTrackingExample
//
//  UIKit view controller demonstrating observation tracking
//

import UIKit
import Observation

class UIKitDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Access the shared data model through traits
    private var model: SharedDataModel? {
        traitCollection.appModel?.sharedData
    }
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let explanationLabel = UILabel()
    private let textLabel = UILabel()
    private let counterLabel = UILabel()
    private let incrementButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let loadDataButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let themeSegmentedControl = UISegmentedControl()
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Configure explanation label
        explanationLabel.numberOfLines = 0
        explanationLabel.font = .preferredFont(forTextStyle: .body)
        explanationLabel.textColor = .secondaryLabel
        explanationLabel.text = """
        This UIKit view demonstrates two powerful iOS 18+ features:
        
        1. Automatic Observation Tracking:
        • UI updates automatically in viewWillLayoutSubviews()
        • No manual KVO or NotificationCenter needed
        • Just read properties and UIKit tracks dependencies
        
        2. Custom Traits Pattern:
        • Observable objects passed through the trait collection
        • Access model via traitCollection.appModel
        • SwiftUI-like environment values for UIKit
        
        The model is shared with SwiftUI through the same trait system!
        """
        
        // Configure text label
        textLabel.font = .preferredFont(forTextStyle: .title2)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        
        // Configure counter label
        counterLabel.font = .monospacedDigitSystemFont(ofSize: 48, weight: .semibold)
        counterLabel.textAlignment = .center
        counterLabel.textColor = .systemBlue
        
        // Configure buttons
        incrementButton.setTitle("Increment", for: .normal)
        incrementButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        incrementButton.configuration = .filled()
        
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        resetButton.configuration = .tinted()
        
        loadDataButton.setTitle("Load Data", for: .normal)
        loadDataButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        loadDataButton.configuration = .bordered()
        
        // Configure activity indicator
        activityIndicator.hidesWhenStopped = true
        
        // Configure theme control
        for (index, theme) in SharedDataModel.Theme.allCases.enumerated() {
            themeSegmentedControl.insertSegment(withTitle: theme.rawValue, at: index, animated: false)
        }
        
        // Create button stack
        let buttonStack = UIStackView(arrangedSubviews: [incrementButton, resetButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 10
        
        // Create load data stack
        let loadDataStack = UIStackView(arrangedSubviews: [loadDataButton, activityIndicator])
        loadDataStack.axis = .horizontal
        loadDataStack.spacing = 10
        loadDataStack.alignment = .center
        
        // Add divider
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add all views to stack
        stackView.addArrangedSubview(explanationLabel)
        stackView.addArrangedSubview(divider)
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(counterLabel)
        stackView.addArrangedSubview(buttonStack)
        stackView.addArrangedSubview(loadDataStack)
        stackView.addArrangedSubview(themeSegmentedControl)
        
        // Add some padding
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        loadDataButton.addTarget(self, action: #selector(loadDataTapped), for: .touchUpInside)
        themeSegmentedControl.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
    }
    
    // MARK: - Observation
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // This is where the magic happens!
        // UIKit tracks these property accesses and re-calls this method when they change
        
        // Update UI based on model state
        textLabel.text = model?.text ?? "No data"
        counterLabel.text = "\(model?.counter ?? 0)"
        
        // Update loading state
        if model?.isLoading == true {
            activityIndicator.startAnimating()
            loadDataButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            loadDataButton.isEnabled = true
        }
        
        // Update theme selection
        if let currentTheme = model?.theme,
           let themeIndex = SharedDataModel.Theme.allCases.firstIndex(of: currentTheme) {
            themeSegmentedControl.selectedSegmentIndex = themeIndex
        }
        
        // Apply theme
        if let theme = model?.theme {
            view.window?.overrideUserInterfaceStyle = theme.userInterfaceStyle
        }
    }
    
    // MARK: - Actions
    
    @objc private func incrementTapped() {
        model?.incrementCounter()
    }
    
    @objc private func resetTapped() {
        model?.resetCounter()
    }
    
    @objc private func loadDataTapped() {
        Task {
            await model?.loadData()
        }
    }
    
    @objc private func themeChanged() {
        let selectedIndex = themeSegmentedControl.selectedSegmentIndex
        guard selectedIndex >= 0, selectedIndex < SharedDataModel.Theme.allCases.count else { return }
        model?.theme = SharedDataModel.Theme.allCases[selectedIndex]
    }
}