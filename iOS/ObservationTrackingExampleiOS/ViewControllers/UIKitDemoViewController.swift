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
    
    private let model: SharedDataModel
    private var observationTracking: ObservationTracking?
    
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
    
    init(model: SharedDataModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observationTracking?.invalidate()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupActions()
        startObservation()
        updateUI()
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
        This UIKit view uses the new Observation framework to track changes in the shared model. 
        
        Key features:
        • Automatic UI updates when observed properties change
        • Fine-grained tracking of specific properties
        • No need for KVO or NotificationCenter
        • Seamless integration with UIKit
        
        The counter and text values are synchronized with the SwiftUI view.
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
    
    private func startObservation() {
        observationTracking = ObservationTracking { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        ObservationTracking.withTracking {
            // Access the properties we want to observe
            textLabel.text = model.text
            counterLabel.text = "\(model.counter)"
            
            // Update loading state
            if model.isLoading {
                activityIndicator.startAnimating()
                loadDataButton.isEnabled = false
            } else {
                activityIndicator.stopAnimating()
                loadDataButton.isEnabled = true
            }
            
            // Update theme selection
            if let themeIndex = SharedDataModel.Theme.allCases.firstIndex(of: model.theme) {
                themeSegmentedControl.selectedSegmentIndex = themeIndex
            }
            
            // Apply theme
            view.window?.overrideUserInterfaceStyle = model.theme.userInterfaceStyle
        } onChange: { [weak self] in
            // This closure is called when any of the accessed properties change
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func incrementTapped() {
        model.incrementCounter()
    }
    
    @objc private func resetTapped() {
        model.resetCounter()
    }
    
    @objc private func loadDataTapped() {
        Task {
            await model.loadData()
        }
    }
    
    @objc private func themeChanged() {
        let selectedIndex = themeSegmentedControl.selectedSegmentIndex
        guard selectedIndex >= 0, selectedIndex < SharedDataModel.Theme.allCases.count else { return }
        model.theme = SharedDataModel.Theme.allCases[selectedIndex]
    }
}