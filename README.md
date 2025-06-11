# ObservationTrackingExample

A demonstration of Swift's @Observable macro working seamlessly across SwiftUI and AppKit on macOS 15+.

## Overview

This example shows how the new `NSObservationTrackingEnabled` feature in macOS 15 brings automatic UI updates to AppKit, similar to what SwiftUI has always had. When enabled, AppKit views can automatically track dependencies on `@Observable` objects and update when those properties change - no KVO or manual notifications needed!

## Key Features

- 🔄 **Bidirectional Sync** - Changes in either window instantly update the other
- 🎯 **Zero Boilerplate** - No KVO, no Combine, no manual UI updates
- 🏗️ **Modern Swift 6** - Uses latest Swift features including `@Observable`, `Sendable`, and strict concurrency
- 🎨 **Educational UI** - Built-in explanations help developers understand how it works

## Requirements

- macOS 15.0+
- Xcode 16.0+
- Swift 6.0+

## How It Works

### 1. Enable Observation Tracking

Add to your `Info.plist`:
```xml
<key>NSObservationTrackingEnabled</key>
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

### 3. Use in AppKit

In your `viewWillLayout()` or other update methods:
```swift
override func viewWillLayout() {
    super.viewWillLayout()
    
    // Reading these properties automatically sets up tracking!
    textField.stringValue = model.message
    label.intValue = model.counter
}
```

That's it! AppKit now tracks these property accesses and recalls `viewWillLayout()` whenever they change.

## What This Example Demonstrates

- **Text synchronization** between SwiftUI TextField and AppKit NSTextField
- **Counter updates** that work from buttons in either framework
- **Toggle state** sharing
- **Color selection** that updates the AppKit window's background
- **Slider values** that sync in real-time

## Architecture

The app uses a clean, modern architecture:
- Single `@Observable` data model shared between both windows
- No delegates, no notifications, no bindings
- Automatic dependency tracking in both frameworks
- Type-safe, Swift 6 compliant code throughout

## License

MIT License - feel free to use this in your own projects!

## Contributing

Feel free to submit issues and enhancement requests!

## Acknowledgments

Thanks to the Swift team for making UI development so much simpler with `@Observable`!