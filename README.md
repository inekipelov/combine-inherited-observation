# CombineInheritedObservation

[![Swift Version](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift Tests](https://github.com/inekipelov/combine-inherited-observation/actions/workflows/swift.yml/badge.svg)](https://github.com/inekipelov/combine-inherited-observation/actions/workflows/swift.yml)

A lightweight Swift library for hierarchical state management and change propagation in SwiftUI applications using Combine and `ObservableObject` protocol.

## Overview

When building complex SwiftUI applications with multiple view models and a hierarchical state structure, propagating state changes through the hierarchy can be challenging. This library provides simple yet powerful extensions to `ObservableObject` that enable:

- **Inheritance**: Child objects can inherit change notifications from parent objects
- **Broadcasting**: Parent objects can be notified of changes in child objects

This enables efficient state synchronization without boilerplate code, keeping your SwiftUI views reactive and up-to-date.

## Requirements

- Swift 5.5+
- iOS 13.0+/ macOS 10.15+/ tvOS 13.0+/ watchOS 6.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/inekipelov/combine-inherited-observation.git", from: "0.1.0")
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
    private(set) var child: Child
    private(set) var children: [Child]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.child = Child()
        self.children = [Child(), Child()]
        
        // Parent will notify its observers when child changes using KeyPath
        self.inherit(objectWillChange: \.child, store: &cancellables)
        
        // Parent will notify its observers when any child in the array changes using KeyPath
        self.inherit(objectWillChange: \.children, store: &cancellables)
        
        // OR Alternatively, directly pass the object
        self.inherit(objectWillChange: child, store: &cancellables)
    }
}
```

You can also use the manual approach with a direct cancellable:

```swift
let parent = Parent()
let child = Child()

// Get cancellable back directly instead of storing it
let inheritCancellable = parent.inherit(objectWillChange: child)

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
    private(set) var child: Child
    
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
// Inherit from multiple objects using variadic parameters
let cancellable = parent.inherit(objectWillChange: childA, childB, childC)

// Inherit from multiple objects with automatic storage
parent.inherit(objectWillChange: childA, childB, childC, store: &cancellables)

// Inherit from an array of objects
let childObjects = [childA, childB, childC]
parent.inherit(objectWillChange: childObjects, store: &cancellables)

// Inheritance with manual count tracking
var changeCount = 0
child.objectWillChange
    .sink { _ in
        changeCount += 1
    }
    .store(in: &cancellables)
```

### Collection Support

You can also broadcast changes from a collection of observable objects:

```swift
// Array of observable objects
let childObjects: [Child] = [Child(), Child(), Child()]

// Broadcast changes from all children to parent
childObjects.broadcast(objectWillChange: parent, store: &cancellables)

// Get cancellable back directly from collection
let broadcastCancellable = childObjects.broadcast(objectWillChange: parent)
```

## Benefits

- **Cleaner Code**: No need for manual publisher management
- **Automatic Memory Management**: Uses weak references to avoid retain cycles
- **Flexible API**: Multiple functions to fit different use cases
- **SwiftUI Integration**: Works seamlessly with SwiftUI's reactive UI updates

## License

This library is released under the MIT License. See [LICENSE](LICENSE) for details.
