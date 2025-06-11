import Cocoa
import Observation

/// AppKit view controller demonstrating automatic observation tracking
/// No KVO, no bindings - just read properties in viewWillLayout()!
@MainActor
final class AppKitViewController: NSViewController, NSTextFieldDelegate {
    private var dataModel: SharedDataModel?
    
    // UI Elements
    private let messageTextField = NSTextField()
    private let counterLabel = NSTextField()
    private let decrementButton = NSButton()
    private let incrementButton = NSButton()
    private let enabledCheckbox = NSButton(checkboxWithTitle: "Feature Enabled", target: nil, action: nil)
    private let colorPopupButton = NSPopUpButton()
    private let sliderValueLabel = NSTextField()
    private let slider = NSSlider()
    private let resetButton = NSButton()
    private let updateIndicator = NSTextField()
    private var lastUpdateTime = Date()
    
    func setDataModel(_ model: SharedDataModel) {
        self.dataModel = model
        
        // Setup actions (no bindings needed with @Observable!)
        messageTextField.target = self
        messageTextField.action = #selector(messageChanged(_:))
        messageTextField.delegate = self
        
        enabledCheckbox.target = self
        enabledCheckbox.action = #selector(enabledChanged(_:))
        
        decrementButton.target = self
        decrementButton.action = #selector(decrementCounter)
        
        incrementButton.target = self
        incrementButton.action = #selector(incrementCounter)
        
        resetButton.target = self
        resetButton.action = #selector(resetAll)
        
        colorPopupButton.target = self
        colorPopupButton.action = #selector(colorChanged(_:))
        
        slider.target = self
        slider.action = #selector(sliderChanged(_:))
        slider.isContinuous = true
        
        view.needsLayout = true
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 550, height: 750))
        view.wantsLayer = true
        
        // Create main container stack
        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.spacing = 0
        mainStack.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Header section
        let headerView = createHeaderSection()
        mainStack.addArrangedSubview(headerView)
        
        // Explanation section
        let explanationView = createExplanationSection()
        mainStack.addArrangedSubview(explanationView)
        
        // Controls section
        let controlsContainer = NSView()
        controlsContainer.wantsLayer = true
        
        let controlsView = createControlsSection()
        controlsContainer.addSubview(controlsView)
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsView.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 20),
            controlsView.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 20),
            controlsView.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -20),
            controlsView.bottomAnchor.constraint(lessThanOrEqualTo: controlsContainer.bottomAnchor, constant: -20)
        ])
        
        mainStack.addArrangedSubview(controlsContainer)
        
        // Footer section
        let footerView = createFooterSection()
        mainStack.addArrangedSubview(footerView)
        
        // Add main stack to view
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure controls growth priority
        headerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        explanationView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        controlsContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
        footerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func createHeaderSection() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .centerX
        
        // Icon
        let titleIcon = NSImageView()
        titleIcon.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        titleIcon.contentTintColor = .systemOrange
        titleIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        stack.addArrangedSubview(titleIcon)
        
        // Title
        let titleLabel = NSTextField(labelWithString: "AppKit Window")
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.alignment = .center
        stack.addArrangedSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = NSTextField(labelWithString: "This window uses traditional AppKit with automatic observation")
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.alignment = .center
        stack.addArrangedSubview(subtitleLabel)
        
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    private func createExplanationSection() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        
        let textView = NSTextView()
        textView.string = """
        🔍 How AppKit Observation Works:
        
        1. In viewWillLayout(), we read properties from our @Observable model
        2. AppKit automatically tracks these property accesses
        3. When any tracked property changes, viewWillLayout() is called again
        4. The UI updates without manual KVO or notifications!
        
        ⚡️ Try it: Change values in either window and watch them sync instantly!
        """
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05)
        textView.font = .systemFont(ofSize: 12)
        textView.textContainerInset = NSSize(width: 15, height: 15)
        textView.isRichText = false
        textView.drawsBackground = true
        
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = false
        scrollView.borderType = .noBorder
        scrollView.autohidesScrollers = true
        
        container.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            scrollView.heightAnchor.constraint(equalToConstant: 140)
        ])
        
        // Add rounded corners
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 8
        scrollView.layer?.masksToBounds = true
        
        return container
    }
    
    private func createControlsSection() -> NSView {
        let gridView = NSGridView()
        gridView.rowSpacing = 24
        gridView.columnSpacing = 20
        
        // Message row
        let messageLabel = createLabel("📝 Message")
        setupMessageTextField()
        gridView.addRow(with: [messageLabel, messageTextField])
        
        // Counter row
        let counterLabelTitle = createLabel("🔢 Counter")
        let counterStack = createCounterStack()
        gridView.addRow(with: [counterLabelTitle, counterStack])
        
        // Toggle row
        let toggleLabel = createLabel("🎛️ Toggle")
        setupEnabledCheckbox()
        gridView.addRow(with: [toggleLabel, enabledCheckbox])
        
        // Color row
        let colorLabel = createLabel("🎨 Theme Color")
        setupColorPopup()
        gridView.addRow(with: [colorLabel, colorPopupButton])
        
        // Slider row
        let sliderLabel = createLabel("📊 Value")
        let sliderStack = createSliderStack()
        gridView.addRow(with: [sliderLabel, sliderStack])
        
        // Configure grid columns
        gridView.column(at: 0).xPlacement = .trailing
        gridView.column(at: 1).xPlacement = .leading
        
        // Add reset button below grid
        let containerStack = NSStackView()
        containerStack.orientation = .vertical
        containerStack.spacing = 30
        containerStack.addArrangedSubview(gridView)
        
        setupResetButton()
        containerStack.addArrangedSubview(resetButton)
        containerStack.setCustomSpacing(40, after: gridView)
        
        return containerStack
    }
    
    private func createLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.alignment = .right
        return label
    }
    
    private func createCounterStack() -> NSView {
        // Setup counter controls
        setupCounterControls()
        
        let stack = NSStackView(views: [decrementButton, counterLabel, incrementButton])
        stack.orientation = .horizontal
        stack.spacing = 16
        stack.alignment = .centerY
        
        return stack
    }
    
    private func createSliderStack() -> NSView {
        setupSliderControls()
        
        let stack = NSStackView(views: [slider, sliderValueLabel])
        stack.orientation = .horizontal
        stack.spacing = 12
        stack.alignment = .centerY
        
        return stack
    }
    
    private func createFooterSection() -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.5).cgColor
        
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .centerY
        
        let syncIcon = NSImageView()
        syncIcon.image = NSImage(systemSymbolName: "arrow.left.arrow.right.circle.fill", accessibilityDescription: nil)
        syncIcon.contentTintColor = .systemOrange
        
        let syncLabel = NSTextField(labelWithString: "Changes sync automatically with SwiftUI window")
        syncLabel.font = .systemFont(ofSize: 11)
        syncLabel.textColor = .secondaryLabelColor
        
        setupUpdateIndicator()
        
        stack.addArrangedSubview(syncIcon)
        stack.addArrangedSubview(syncLabel)
        stack.addArrangedSubview(updateIndicator)
        
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    private func setupMessageTextField() {
        messageTextField.placeholderString = "Type here and watch it appear in SwiftUI window..."
        messageTextField.bezelStyle = .roundedBezel
        messageTextField.font = .systemFont(ofSize: 13)
        messageTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
    }
    
    private func setupCounterControls() {
        // Counter label
        counterLabel.stringValue = "0"
        counterLabel.isEditable = false
        counterLabel.isBordered = false
        counterLabel.isSelectable = false
        counterLabel.alignment = .center
        counterLabel.font = .systemFont(ofSize: 36, weight: .bold)
        counterLabel.textColor = .labelColor
        counterLabel.backgroundColor = .clear
        counterLabel.drawsBackground = false
        counterLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        
        // Decrement button
        decrementButton.image = NSImage(systemSymbolName: "minus.circle.fill", accessibilityDescription: "Decrement")
        decrementButton.bezelStyle = .regularSquare
        decrementButton.isBordered = false
        decrementButton.contentTintColor = .systemRed
        decrementButton.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        
        // Increment button
        incrementButton.image = NSImage(systemSymbolName: "plus.circle.fill", accessibilityDescription: "Increment")
        incrementButton.bezelStyle = .regularSquare
        incrementButton.isBordered = false
        incrementButton.contentTintColor = .systemGreen
        incrementButton.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
    }
    
    private func setupEnabledCheckbox() {
        enabledCheckbox.font = .systemFont(ofSize: 13)
    }
    
    private func setupColorPopup() {
        colorPopupButton.removeAllItems()
        let colors = [("Blue", NSColor.systemBlue), ("Red", NSColor.systemRed), 
                     ("Green", NSColor.systemGreen), ("Yellow", NSColor.systemYellow)]
        for (name, color) in colors {
            colorPopupButton.addItem(withTitle: name)
            if let item = colorPopupButton.lastItem {
                let colorWell = NSView(frame: NSRect(x: 0, y: 0, width: 12, height: 12))
                colorWell.wantsLayer = true
                colorWell.layer?.backgroundColor = color.cgColor
                colorWell.layer?.cornerRadius = 6
                item.image = colorWell.snapshot()
            }
        }
        colorPopupButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
    }
    
    private func setupSliderControls() {
        // Slider value label
        sliderValueLabel.stringValue = "50%"
        sliderValueLabel.isEditable = false
        sliderValueLabel.isBordered = false
        sliderValueLabel.isSelectable = false
        sliderValueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        sliderValueLabel.alignment = .right
        sliderValueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 45).isActive = true
        
        // Slider
        slider.sliderType = .linear
        slider.minValue = 0
        slider.maxValue = 100
        slider.doubleValue = 50
        slider.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
    }
    
    private func setupResetButton() {
        resetButton.title = "Reset All Values"
        resetButton.image = NSImage(systemSymbolName: "arrow.counterclockwise.circle.fill", accessibilityDescription: nil)
        resetButton.bezelStyle = .rounded
        resetButton.controlSize = .large
        resetButton.keyEquivalent = "r"
        resetButton.keyEquivalentModifierMask = .command
        resetButton.imagePosition = .imageLeading
    }
    
    private func setupUpdateIndicator() {
        updateIndicator.stringValue = "Last update: Just now"
        updateIndicator.font = .systemFont(ofSize: 11)
        updateIndicator.textColor = .tertiaryLabelColor
        updateIndicator.isEditable = false
        updateIndicator.isBordered = false
        updateIndicator.alignment = .center
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        guard let model = dataModel else { return }
        
        // This is where the magic happens!
        // AppKit tracks these property accesses and re-calls this method when they change
        
        // Update all UI elements to match the model
        messageTextField.stringValue = model.message
        counterLabel.stringValue = "\(model.counter)"
        enabledCheckbox.state = model.isEnabled ? .on : .off
        
        if let index = colorPopupButton.itemTitles.firstIndex(of: model.selectedColor) {
            colorPopupButton.selectItem(at: index)
        }
        
        sliderValueLabel.stringValue = "\(Int(model.sliderValue))%"
        slider.doubleValue = model.sliderValue
        
        // Update background color based on selection
        let backgroundColor: NSColor
        switch model.selectedColor {
        case "Blue":
            backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05)
        case "Red":
            backgroundColor = NSColor.systemRed.withAlphaComponent(0.05)
        case "Green":
            backgroundColor = NSColor.systemGreen.withAlphaComponent(0.05)
        case "Yellow":
            backgroundColor = NSColor.systemYellow.withAlphaComponent(0.05)
        default:
            backgroundColor = NSColor.controlBackgroundColor
        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            view.animator().layer?.backgroundColor = backgroundColor.cgColor
        }
        
        // Update the indicator
        updateIndicator.stringValue = "Last update: Just now"
        lastUpdateTime = Date()
        
        // Animate the update indicator
        updateIndicator.alphaValue = 1.0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            updateIndicator.animator().alphaValue = 0.5
        })
    }
    
    // MARK: - Actions
    
    @objc private func decrementCounter() {
        dataModel?.decrementCounter()
    }
    
    @objc private func incrementCounter() {
        dataModel?.incrementCounter()
    }
    
    @objc private func colorChanged(_ sender: NSPopUpButton) {
        if let selectedTitle = sender.selectedItem?.title {
            dataModel?.selectedColor = selectedTitle
        }
    }
    
    @objc private func sliderChanged(_ sender: NSSlider) {
        dataModel?.sliderValue = sender.doubleValue
    }
    
    @objc private func resetAll() {
        dataModel?.reset()
    }
    
    @objc private func messageChanged(_ sender: NSTextField) {
        dataModel?.message = sender.stringValue
    }
    
    @objc private func enabledChanged(_ sender: NSButton) {
        dataModel?.isEnabled = sender.state == .on
    }
}

// MARK: - NSTextFieldDelegate

extension AppKitViewController {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            dataModel?.message = textField.stringValue
        }
    }
}

// MARK: - Helper Extensions

extension NSView {
    func snapshot() -> NSImage? {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
}

// MARK: - Window Controller

@MainActor
final class AppKitWindowController: NSWindowController {
    convenience init(dataModel: SharedDataModel) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 750),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "AppKit Observer Example"
        window.minSize = NSSize(width: 500, height: 700)
        window.center()
        
        // Position the window to the right of the main window
        if let mainWindow = NSApp.mainWindow {
            var frame = window.frame
            frame.origin.x = mainWindow.frame.maxX + 20
            frame.origin.y = mainWindow.frame.origin.y
            window.setFrame(frame, display: true, animate: false)
        }
        
        self.init(window: window)
        
        let viewController = AppKitViewController()
        viewController.setDataModel(dataModel)
        window.contentViewController = viewController
        
        // Ensure the window content is visible
        window.layoutIfNeeded()
    }
}