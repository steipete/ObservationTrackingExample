# ObservationTrackingExample

A demonstration of Swift's @Observable macro working seamlessly across SwiftUI, UIKit, and AppKit on iOS 18+ and macOS 15+.

## Overview

This example shows how the new observation tracking features in iOS 18 and macOS 15 bring automatic UI updates to UIKit and AppKit, similar to what SwiftUI has always had. When enabled, UIKit and AppKit views can automatically track dependencies on `@Observable` objects and update when those properties change - no KVO or manual notifications needed!

The project includes:
- **macOS Example**: SwiftUI + AppKit windows that sync data automatically
- **iOS Example**: UIKit split view controller with automatic observation tracking and custom traits

## Key Features

- 🔄 **Bidirectional Sync** - Changes in either window instantly update the other
- 🎯 **Zero Boilerplate** - No KVO, no Combine, no manual UI updates
- 🏗️ **Modern Swift 6** - Uses latest Swift features including `@Observable`, `Sendable`, and strict concurrency
- 🎨 **Educational UI** - Built-in explanations help developers understand how it works

## Requirements

- iOS 18.0+ / macOS 15.5+
- Xcode 26.0+ (the iOS 26 APIs require the matching SDK, even with availability checks)
- Swift 6.0+

## Build and Test

The workspace contains both examples and their test suites. There are no third-party dependencies to install.

```sh
xcodebuild -workspace ObservationTrackingExample.xcworkspace \
  -scheme ObservationTrackingExample -destination 'platform=macOS' build test

xcodebuild -workspace ObservationTrackingExample.xcworkspace \
  -scheme ObservationTrackingExampleiOS \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build test
```

Choose an installed iOS simulator from `xcrun simctl list devices available` if your Xcode installation has different runtimes. Select your own signing team for local development.

GitHub Actions builds both apps and runs all macOS unit/UI tests and iOS unit tests on macOS 26 with Xcode 26.6. The workflow runs for pull requests and pushes to `main`, using ad-hoc signing on disposable runners so no signing credentials are required.

## How It Works

### 1. Enable Observation Tracking

Add to your `Info.plist`:

For macOS:
```xml
<key>NSObservationTrackingEnabled</key>
<true/>
```

For iOS:
```xml
<key>UIObservationTrackingEnabled</key>
<true/>
```

### 2. Create an Observable Model

```swift
@Observable
@MainActor
final class SharedDataModel: Sendable {
    var message = "Hello!"
    var counter = 0
    // ... more properties
}
```

### 3. Use in UIKit/AppKit

In UIKit's `updateProperties()` (iOS 26+) or `viewWillLayoutSubviews()` (earlier):
```swift
@available(iOS 26.0, *)
override func updateProperties() {
    super.updateProperties()
    
    // Reading these properties automatically sets up tracking!
    textLabel.text = model.message
    counterLabel.text = "\(model.counter)"
}

override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if #available(iOS 26.0, *) { return }
    textLabel.text = model.message
    counterLabel.text = "\(model.counter)"
}
```

In AppKit's `viewWillLayout()`:
```swift
override func viewWillLayout() {
    super.viewWillLayout()
    
    // Reading these properties automatically sets up tracking!
    textField.stringValue = model.message
    label.intValue = model.counter
}
```

That's it! UIKit/AppKit now tracks these property accesses and recalls the method whenever they change.

## What This Example Demonstrates

### macOS Example
- **Text synchronization** between SwiftUI TextField and AppKit NSTextField
- **Counter updates** that work from buttons in either framework
- **Toggle state** sharing
- **Color selection** that updates the AppKit window's background
- **Slider values** that sync in real-time

### iOS Example
- **Split view controller** with master-detail pattern
- **Custom traits** for passing observable objects through view hierarchy
- **Theme switching** (Light/Dark/Auto) that applies app-wide
- **Async data loading** with proper UI feedback
- **Automatic UI updates** without delegates or notifications

## Architecture

The app uses a clean, modern architecture:
- Single `@Observable` data model shared between windows/views
- No delegates, no notifications, no bindings
- Automatic dependency tracking in all frameworks
- Type-safe, Swift 6 compliant code throughout

### iOS Custom Traits Pattern

The iOS example demonstrates how to use custom traits with observable objects:

```swift
// Define a custom trait
struct AppModelTrait: UITraitDefinition {
    static let defaultValue: AppModel? = nil
}

// Inject at the root
rootViewController.traitOverrides.appModel = appModel

// Access anywhere in the hierarchy
@available(iOS 26.0, *)
override func updateProperties() {
    guard let model = traitCollection.appModel else { return }
    // Use model properties - automatic tracking!
}
```

## License

MIT License - feel free to use this in your own projects!

## Contributing

Feel free to submit issues and enhancement requests!

## Acknowledgments

Thanks to the Swift team for making UI development so much simpler with `@Observable`!
