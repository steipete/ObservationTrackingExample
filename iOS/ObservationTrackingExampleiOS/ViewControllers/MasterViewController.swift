//
//  MasterViewController.swift
//  ObservationTrackingExample
//
//  Master view controller showing the list of items
//

import UIKit
import Observation

/// Master view controller that displays the list of items
final class MasterViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// Cell identifier for reuse
    private let cellIdentifier = "ItemCell"
    
    /// Date formatter for timestamps
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Items"
        
        // Configure table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        // Set up navigation items
        setupNavigationItems()
        
        // Set up observation tracking
        setupObservation()
        
        // Configure refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    // MARK: - Setup
    
    private func setupNavigationItems() {
        // Add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemTapped))
        
        // Settings button
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsTapped))
        
        navigationItem.rightBarButtonItems = [addButton, settingsButton]
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func setupObservation() {
        guard let appModel else { return }
        
        // Observe items array changes
        _ = withObservationTracking {
            appModel.sharedData.items
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleItemsChange()
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
        
        // Observe theme changes to update cell appearance
        _ = withObservationTracking {
            appModel.sharedData.theme
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleThemeChange()
            }
        }
        
        // Observe preferences
        _ = withObservationTracking {
            appModel.preferences.showTimestamps
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handlePreferencesChange()
            }
        }
    }
    
    // MARK: - Change Handlers
    
    private func handleItemsChange() {
        tableView.reloadData()
        
        // Re-establish observation
        guard let appModel else { return }
        _ = withObservationTracking {
            appModel.sharedData.items
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleItemsChange()
            }
        }
    }
    
    private func handleLoadingStateChange() {
        guard let appModel else { return }
        
        if appModel.sharedData.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
        
        // Re-establish observation
        _ = withObservationTracking {
            appModel.sharedData.isLoading
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleLoadingStateChange()
            }
        }
    }
    
    private func handleThemeChange() {
        tableView.reloadData()
        
        // Re-establish observation
        guard let appModel else { return }
        _ = withObservationTracking {
            appModel.sharedData.theme
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handleThemeChange()
            }
        }
    }
    
    private func handlePreferencesChange() {
        tableView.reloadData()
        
        // Re-establish observation
        guard let appModel else { return }
        _ = withObservationTracking {
            appModel.preferences.showTimestamps
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.handlePreferencesChange()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func addItemTapped() {
        appModel?.sharedData.addItem()
    }
    
    @objc private func settingsTapped() {
        let alert = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        // Theme options
        for theme in SharedDataModel.Theme.allCases {
            let action = UIAlertAction(title: theme.rawValue, style: .default) { [weak self] _ in
                self?.appModel?.sharedData.theme = theme
            }
            if appModel?.sharedData.theme == theme {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure for iPad
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.last
        }
        
        present(alert, animated: true)
    }
    
    @objc private func handleRefresh() {
        Task {
            await appModel?.sharedData.loadData()
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appModel?.sharedData.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let item = appModel?.sharedData.items[safe: indexPath.row] else {
            return cell
        }
        
        // Configure cell
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        
        if appModel?.preferences.showTimestamps == true {
            content.secondaryText = "\(item.subtitle) • \(dateFormatter.string(from: item.timestamp))"
        } else {
            content.secondaryText = item.subtitle
        }
        
        cell.contentConfiguration = content
        
        // Show selection indicator
        if item.id == appModel?.sharedData.selectedItem?.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = appModel?.sharedData.items[safe: indexPath.row] else { return }
        
        // Update selection
        appModel?.sharedData.selectedItem = item
        
        // Reload to update checkmarks
        tableView.reloadData()
        
        // Show detail in compact width
        if splitViewController?.isCollapsed == true {
            splitViewController?.showDetailViewController(splitViewController!.viewController(for: .secondary)!, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            appModel?.sharedData.removeItem(at: indexPath.row)
        }
    }
}

// MARK: - Collection Safe Subscript

private extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}