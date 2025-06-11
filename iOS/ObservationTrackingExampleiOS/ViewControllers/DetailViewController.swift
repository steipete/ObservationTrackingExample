//
//  DetailViewController.swift
//  ObservationTrackingExample
//
//  Detail view controller showing the selected item
//

import UIKit
import Observation

/// Detail view controller that displays the selected item's information
final class DetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let detailTextView = UITextView()
    private let counterLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let actionStackView = UIStackView()
    private let incrementButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let loadDataButton = UIButton(type: .system)
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detail"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupConstraints()
        setupObservation()
        updateUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Configure content stack
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        // Configure title label
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        // Configure subtitle label
        subtitleLabel.font = .preferredFont(forTextStyle: .headline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        
        // Configure detail text view
        detailTextView.font = .preferredFont(forTextStyle: .body)
        detailTextView.isEditable = false
        detailTextView.isScrollEnabled = false
        detailTextView.backgroundColor = .secondarySystemBackground
        detailTextView.layer.cornerRadius = 8
        detailTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Configure counter label
        counterLabel.font = .monospacedDigitSystemFont(ofSize: 48, weight: .semibold)
        counterLabel.textAlignment = .center
        counterLabel.textColor = .systemBlue
        
        // Configure action buttons
        actionStackView.axis = .horizontal
        actionStackView.spacing = 16
        actionStackView.distribution = .fillEqually
        
        incrementButton.setTitle("Increment", for: .normal)
        incrementButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        incrementButton.backgroundColor = .systemBlue
        incrementButton.setTitleColor(.white, for: .normal)
        incrementButton.layer.cornerRadius = 8
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        resetButton.backgroundColor = .systemRed
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        
        loadDataButton.setTitle("Load Data", for: .normal)
        loadDataButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        loadDataButton.backgroundColor = .systemGreen
        loadDataButton.setTitleColor(.white, for: .normal)
        loadDataButton.layer.cornerRadius = 8
        loadDataButton.addTarget(self, action: #selector(loadDataTapped), for: .touchUpInside)
        
        // Configure loading indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        // Add buttons to action stack
        actionStackView.addArrangedSubview(incrementButton)
        actionStackView.addArrangedSubview(resetButton)
        
        // Add views to content stack
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(detailTextView)
        contentStackView.addArrangedSubview(counterLabel)
        contentStackView.addArrangedSubview(actionStackView)
        contentStackView.addArrangedSubview(loadDataButton)
        
        // Add spacing
        contentStackView.setCustomSpacing(30, after: detailTextView)
        contentStackView.setCustomSpacing(30, after: counterLabel)
        
        // Navigation items
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Toggle Mode",
            style: .plain,
            target: self,
            action: #selector(toggleModeTapped)
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content stack
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            // Button heights
            incrementButton.heightAnchor.constraint(equalToConstant: 44),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            loadDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Detail text view minimum height
            detailTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Observation Setup
    
    private func setupObservation() {
        guard let appModel else { return }
        
        // Observe selected item
        _ = withObservationTracking {
            appModel.sharedData.selectedItem
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleSelectedItemChange()
            }
        }
        
        // Observe counter
        _ = withObservationTracking {
            appModel.sharedData.counter
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleCounterChange()
            }
        }
        
        // Observe loading state
        _ = withObservationTracking {
            appModel.sharedData.isLoading
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleLoadingStateChange()
            }
        }
        
        // Observe text
        _ = withObservationTracking {
            appModel.sharedData.text
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleTextChange()
            }
        }
    }
    
    // MARK: - Change Handlers
    
    private func handleSelectedItemChange() {
        updateUI()
        
        // Re-establish observation
        guard let appModel else { return }
        _ = withObservationTracking {
            appModel.sharedData.selectedItem
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleSelectedItemChange()
            }
        }
    }
    
    private func handleCounterChange() {
        updateCounterLabel()
        
        // Re-establish observation
        guard let appModel else { return }
        _ = withObservationTracking {
            appModel.sharedData.counter
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleCounterChange()
            }
        }
    }
    
    private func handleLoadingStateChange() {
        updateLoadingState()
        
        // Re-establish observation
        guard let appModel else { return }
        _ = withObservationTracking {
            appModel.sharedData.isLoading
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleLoadingStateChange()
            }
        }
    }
    
    private func handleTextChange() {
        updateUI()
        
        // Re-establish observation
        guard let appModel else { return }
        _ = withObservationTracking {
            appModel.sharedData.text
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleTextChange()
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        guard let appModel else { return }
        
        if let item = appModel.sharedData.selectedItem {
            titleLabel.text = item.title
            subtitleLabel.text = item.subtitle
            detailTextView.text = """
            \(item.detail)
            
            Current Status: \(appModel.sharedData.text)
            
            Created: \(item.timestamp.formatted())
            """
        } else {
            titleLabel.text = "No Selection"
            subtitleLabel.text = "Select an item from the list"
            detailTextView.text = "No item selected. Please select an item from the master list to view its details here."
        }
        
        updateCounterLabel()
    }
    
    private func updateCounterLabel() {
        guard let appModel else { return }
        counterLabel.text = "\(appModel.sharedData.counter)"
    }
    
    private func updateLoadingState() {
        guard let appModel else { return }
        
        if appModel.sharedData.isLoading {
            loadingIndicator.startAnimating()
            loadDataButton.isEnabled = false
            loadDataButton.alpha = 0.5
        } else {
            loadingIndicator.stopAnimating()
            loadDataButton.isEnabled = true
            loadDataButton.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    
    @objc private func incrementTapped() {
        appModel?.sharedData.incrementCounter()
    }
    
    @objc private func resetTapped() {
        appModel?.sharedData.resetCounter()
    }
    
    @objc private func loadDataTapped() {
        Task {
            await appModel?.sharedData.loadData()
        }
    }
    
    @objc private func toggleModeTapped() {
        appModel?.toggleDisplayMode()
    }
}