import Cocoa
import Observation

class AppKitViewController: NSViewController {
    private var dataModel: SharedDataModel?
    
    // UI Elements
    private let explanationTextView = NSTextView()
    private let messageTextField = NSTextField()
    private let messageLabel = NSTextField()
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
        slider.minValue = 0
        slider.maxValue = 100
        
        view.needsLayout = true
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 550, height: 700))
        view.wantsLayer = true
        
        // Header with title and icon
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
        
        let titleStack = NSStackView(views: [titleIcon, titleLabel, subtitleLabel])
        titleStack.orientation = .vertical
        titleStack.spacing = 8
        titleStack.alignment = .centerX
        
        // Setup explanation text
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
        
        // Message input setup
        messageLabel.stringValue = "Text Input"
        messageLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        messageLabel.isEditable = false
        messageLabel.isBordered = false
        messageLabel.isSelectable = false
        
        messageTextField.placeholderString = "Type here and watch it appear in SwiftUI window..."
        messageTextField.isEditable = true
        messageTextField.isBordered = true
        messageTextField.bezelStyle = .roundedBezel
        messageTextField.font = .systemFont(ofSize: 13)
        
        // Counter display setup
        counterLabel.isEditable = false
        counterLabel.isBordered = false
        counterLabel.isSelectable = false
        counterLabel.alignment = .center
        counterLabel.font = .systemFont(ofSize: 36, weight: .bold)
        counterLabel.textColor = .labelColor
        
        // Style the increment/decrement buttons
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
        
        // Color picker setup
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
        
        // Slider setup
        sliderValueLabel.isEditable = false
        sliderValueLabel.isBordered = false
        sliderValueLabel.isSelectable = false
        sliderValueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        
        slider.sliderType = .linear
        slider.numberOfTickMarks = 11
        slider.allowsTickMarkValuesOnly = false
        
        // Reset button setup
        resetButton.title = "Reset All Values"
        resetButton.image = NSImage(systemSymbolName: "arrow.counterclockwise.circle.fill", accessibilityDescription: nil)
        resetButton.bezelStyle = .rounded
        resetButton.keyEquivalent = "r"
        resetButton.imagePosition = .imageLeading
        
        // Update indicator
        updateIndicator.stringValue = "Last update: Just now"
        updateIndicator.font = .systemFont(ofSize: 11)
        updateIndicator.textColor = .tertiaryLabelColor
        updateIndicator.isEditable = false
        updateIndicator.isBordered = false
        updateIndicator.alignment = .center
        
        // Create styled group boxes
        let messageStack = NSStackView(views: [messageLabel, messageTextField])
        messageStack.orientation = .vertical
        messageStack.spacing = 8
        messageStack.alignment = .leading
        messageStack.setHuggingPriority(.defaultHigh, for: .vertical)
        
        // Make text field full width
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageTextField.widthAnchor.constraint(equalTo: messageStack.widthAnchor)
        ])
        
        let messageBox = createGroupBox(title: "📝 Message", content: messageStack)
        
        let counterStack = NSStackView(views: [decrementButton, counterLabel, incrementButton])
        counterStack.orientation = .horizontal
        counterStack.spacing = 20
        counterStack.alignment = .centerY
        let counterBox = createGroupBox(title: "🔢 Counter", content: counterStack)
        
        let colorLabel = NSTextField(labelWithString: "Theme Color")
        colorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        let colorStack = NSStackView(views: [colorLabel, colorPopupButton])
        colorStack.orientation = .horizontal
        colorStack.spacing = 10
        
        let sliderLabel = NSTextField(labelWithString: "Value")
        sliderLabel.font = .systemFont(ofSize: 13, weight: .medium)
        let sliderLabelStack = NSStackView(views: [sliderLabel, sliderValueLabel])
        sliderLabelStack.orientation = .horizontal
        sliderLabelStack.spacing = 10
        
        let sliderStack = NSStackView(views: [sliderLabelStack, slider])
        sliderStack.orientation = .vertical
        sliderStack.spacing = 8
        sliderStack.alignment = .leading
        sliderStack.setHuggingPriority(.defaultHigh, for: .vertical)
        
        // Make slider full width
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.widthAnchor.constraint(equalTo: sliderStack.widthAnchor)
        ])
        
        let controlsStack = NSStackView(views: [enabledCheckbox, colorStack, sliderStack])
        controlsStack.orientation = .vertical
        controlsStack.spacing = 16
        controlsStack.alignment = .leading
        let controlsBox = createGroupBox(title: "🎛️ Controls", content: controlsStack)
        
        // Footer with sync indicator
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
        
        // Add a spacer view
        let spacerView = NSView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let mainStack = NSStackView(views: [
            titleStack,
            explanationScrollView,
            messageBox,
            counterBox,
            controlsBox,
            spacerView,
            resetButton,
            footerStack
        ])
        mainStack.orientation = .vertical
        mainStack.spacing = 16
        mainStack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mainStack.alignment = .leading
        mainStack.distribution = .fill
        
        // Set constraints for explanation view
        explanationScrollView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Make all boxes stretch to full width
        for subview in mainStack.arrangedSubviews {
            if subview != spacerView {
                subview.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    subview.widthAnchor.constraint(equalTo: mainStack.widthAnchor, constant: -40) // Account for edge insets
                ])
            }
        }
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
        
        // Update the indicator to show when updates happen
        updateIndicator.stringValue = "Last update: Just now"
        lastUpdateTime = Date()
        
        // Animate the update indicator
        updateIndicator.alphaValue = 1.0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            updateIndicator.animator().alphaValue = 0.5
        })
    }
    
    private func createGroupBox(title: String, content: NSView) -> NSBox {
        let box = NSBox()
        box.title = title
        box.titleFont = .systemFont(ofSize: 13, weight: .medium)
        box.contentView = content
        box.boxType = .primary
        box.cornerRadius = 8
        box.contentViewMargins = NSSize(width: 16, height: 16)
        return box
    }
    
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

// Helper extension for creating image snapshots
extension NSView {
    func snapshot() -> NSImage? {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
}

class AppKitWindowController: NSWindowController {
    convenience init(dataModel: SharedDataModel) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 700),
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