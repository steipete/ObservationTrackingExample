import Cocoa
import Observation

/// AppKit view controller demonstrating automatic observation tracking
/// No KVO, no bindings - just read properties in viewWillLayout()!
@MainActor
final class AppKitViewController: NSViewController, NSTextFieldDelegate {
    private var dataModel: SharedDataModel?
    
    // UI Elements
    private let explanationTextView = NSTextView()
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
        view = NSView(frame: NSRect(x: 0, y: 0, width: 550, height: 700))
        view.wantsLayer = true
        
        // Header
        let titleIcon = NSImageView()
        titleIcon.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: nil)
        titleIcon.contentTintColor = .systemOrange
        titleIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        let titleLabel = NSTextField(labelWithString: "AppKit Window")
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.alignment = .center
        
        let subtitleLabel = NSTextField(labelWithString: "This window uses traditional AppKit with automatic observation")
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.alignment = .center
        
        // Explanation
        explanationTextView.string = """
        🔍 How AppKit Observation Works:
        
        1. In viewWillLayout(), we read properties from our @Observable model
        2. AppKit automatically tracks these property accesses
        3. When any tracked property changes, viewWillLayout() is called again
        4. The UI updates without manual KVO or notifications!
        
        ⚡️ Try it: Change values in either window and watch them sync instantly!
        """
        explanationTextView.isEditable = false
        explanationTextView.isSelectable = false
        explanationTextView.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05)
        explanationTextView.font = .systemFont(ofSize: 12)
        explanationTextView.textContainerInset = NSSize(width: 10, height: 10)
        
        let explanationScrollView = NSScrollView()
        explanationScrollView.documentView = explanationTextView
        explanationScrollView.hasVerticalScroller = false
        explanationScrollView.borderType = .noBorder
        
        // Setup controls
        setupControls()
        
        // Create grid view for controls
        let gridView = NSGridView()
        gridView.rowSpacing = 20
        gridView.columnSpacing = 16
        
        // Message row
        let messageLabel = NSTextField(labelWithString: "📝 Message")
        messageLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        gridView.addRow(with: [messageLabel, messageTextField])
        
        // Counter row
        let counterLabelTitle = NSTextField(labelWithString: "🔢 Counter")
        counterLabelTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        let counterStack = NSStackView(views: [decrementButton, counterLabel, incrementButton])
        counterStack.orientation = .horizontal
        counterStack.spacing = 20
        counterStack.alignment = .centerY
        gridView.addRow(with: [counterLabelTitle, counterStack])
        
        // Toggle row
        let toggleLabel = NSTextField(labelWithString: "🎛️ Toggle")
        toggleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        gridView.addRow(with: [toggleLabel, enabledCheckbox])
        
        // Color row
        let colorLabel = NSTextField(labelWithString: "🎨 Theme Color")
        colorLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        gridView.addRow(with: [colorLabel, colorPopupButton])
        
        // Slider row
        let sliderLabelTitle = NSTextField(labelWithString: "📊 Value")
        sliderLabelTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        let sliderStack = NSStackView(views: [slider, sliderValueLabel])
        sliderStack.orientation = .horizontal
        sliderStack.spacing = 12
        sliderStack.alignment = .centerY
        gridView.addRow(with: [sliderLabelTitle, sliderStack])
        
        // Configure grid columns
        gridView.column(at: 0).xPlacement = .trailing
        gridView.column(at: 1).xPlacement = .leading
        gridView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        // Footer
        let syncIcon = NSImageView()
        syncIcon.image = NSImage(systemSymbolName: "arrow.left.arrow.right.circle.fill", accessibilityDescription: nil)
        syncIcon.contentTintColor = .systemOrange
        
        let syncLabel = NSTextField(labelWithString: "Changes sync automatically with SwiftUI window")
        syncLabel.font = .systemFont(ofSize: 11)
        syncLabel.textColor = .secondaryLabelColor
        
        let footerStack = NSStackView(views: [syncIcon, syncLabel, updateIndicator])
        footerStack.orientation = .horizontal
        footerStack.spacing = 8
        footerStack.alignment = .centerY
        
        // Main stack
        let mainStack = NSStackView(views: [
            titleIcon,
            titleLabel,
            subtitleLabel,
            explanationScrollView,
            gridView,
            NSView(), // Spacer
            resetButton,
            footerStack
        ])
        mainStack.orientation = .vertical
        mainStack.spacing = 16
        mainStack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mainStack.setCustomSpacing(8, after: titleIcon)
        mainStack.setCustomSpacing(4, after: titleLabel)
        mainStack.setCustomSpacing(24, after: subtitleLabel)
        mainStack.setCustomSpacing(24, after: explanationScrollView)
        
        // Configure spacer
        if let spacer = mainStack.arrangedSubviews.first(where: { $0.className == "NSView" }) {
            spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
        
        // Add constraints
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set fixed heights
        explanationScrollView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        // Make text field wider
        messageTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
        colorPopupButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        slider.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
    }
    
    private func setupControls() {
        // Message text field
        messageTextField.placeholderString = "Type here and watch it appear in SwiftUI window..."
        messageTextField.bezelStyle = .roundedBezel
        messageTextField.font = .systemFont(ofSize: 13)
        
        // Counter
        counterLabel.isEditable = false
        counterLabel.isBordered = false
        counterLabel.isSelectable = false
        counterLabel.alignment = .center
        counterLabel.font = .systemFont(ofSize: 36, weight: .bold)
        counterLabel.textColor = .labelColor
        
        decrementButton.image = NSImage(systemSymbolName: "minus.circle.fill", accessibilityDescription: "Decrement")
        decrementButton.bezelStyle = .regularSquare
        decrementButton.isBordered = false
        decrementButton.contentTintColor = .systemRed
        decrementButton.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        
        incrementButton.image = NSImage(systemSymbolName: "plus.circle.fill", accessibilityDescription: "Increment")
        incrementButton.bezelStyle = .regularSquare
        incrementButton.isBordered = false
        incrementButton.contentTintColor = .systemGreen
        incrementButton.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        
        // Color picker
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
        
        // Slider
        sliderValueLabel.isEditable = false
        sliderValueLabel.isBordered = false
        sliderValueLabel.isSelectable = false
        sliderValueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        sliderValueLabel.alignment = .right
        
        slider.sliderType = .linear
        slider.minValue = 0
        slider.maxValue = 100
        
        // Reset button
        resetButton.title = "Reset All Values"
        resetButton.image = NSImage(systemSymbolName: "arrow.counterclockwise.circle.fill", accessibilityDescription: nil)
        resetButton.bezelStyle = .rounded
        resetButton.controlSize = .large
        resetButton.keyEquivalent = "r"
        resetButton.keyEquivalentModifierMask = .command
        resetButton.imagePosition = .imageLeading
        
        // Update indicator
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
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 650),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "AppKit Observer Example"
        window.minSize = NSSize(width: 500, height: 600)
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