# CombineInheritedObservation

[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-blue.svg)](https://www.apple.com)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A lightweight Swift library for hierarchical state management and change propagation in SwiftUI applications using Combine and `ObservableObject` protocol.

## Overview

When building complex SwiftUI applications with multiple view models and a hierarchical state structure, propagating state changes through the hierarchy can be challenging. This library provides simple yet powerful extensions to `ObservableObject` that enable:

- **Inheritance**: Child objects can inherit change notifications from parent objects
- **Broadcasting**: Parent objects can be notified of changes in child objects

This enables efficient state synchronization without boilerplate code, keeping your SwiftUI views reactive and up-to-date.

## Requirements

- Swift 5.5+
- iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+
- Combine framework

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/username/combine-inherited-observation.git", from: "1.0.0")
]
```

Or add it directly in Xcode using File → Swift Packages → Add Package Dependency...

## Usage

### Inherit Changes from Child to Parent

When a child object changes, you might want the parent to also notify its observers. This is where the `inherit` extension comes in:

```swift
class Child: ObservableObject {
    @Published private(set) var value: Int = 0
    func increment() {
        value += 1
    }
}

class Parent: ObservableObject {
    @Published private(set) var child: Child
    @Published private(set) var children: [Child]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.child = Child()
        self.children = [Child(), Child()]
        
        // Parent will notify its observers when child changes
        self.inherit(objectWillChange: child, store: &cancellables)
        
        // Parent will notify its observers when any child in the array changes
        self.inherit(objectWillChange: children, store: &cancellables)
    }
}
```

You can also use the manual approach with a direct cancellable:

```swift
let parent = Parent()
let child = Child()

// Get cancellable back directly instead of storing it
let inheritCancellable = child.inherit(objectWillChange: parent)

// Later, you can cancel the subscription
inheritCancellable.cancel()
```

### Broadcast Changes from Child to Parent

When a child object changes, you may want to automatically notify the parent's observers:

```swift
class Child: ObservableObject {
    @Published private(set) var value: Int = 0
    func increment() {
        value += 1
    }
}

class Parent: ObservableObject {
    @Published private(set) var child: Child
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.child = Child()
        
        // When child changes, parent will also notify its observers
        child.broadcast(objectWillChange: self, store: &cancellables)
    }
}
```

### Advanced Usage

You can inherit changes from multiple objects at once:

```swift
// Inherit from multiple parents
viewModel.inherit(objectWillChange: parentA, parentB, parentC, store: &cancellables)

// Multiple inheritance with a varargs syntax
let cancellable = child.inherit(objectWillChange: parentA, parentB, parentC)

// Inheritance with manual count tracking
var childChangeCount = 0
child.objectWillChange
    .sink { _ in
        childChangeCount += 1
    }
    .store(in: &cancellables)
```

## Benefits

- **Cleaner Code**: No need for manual publisher management
- **Automatic Memory Management**: Uses weak references to avoid retain cycles
- **Flexible API**: Multiple functions to fit different use cases
- **SwiftUI Integration**: Works seamlessly with SwiftUI's reactive UI updates

## License

This library is released under the MIT License. See [LICENSE](LICENSE) for details.
