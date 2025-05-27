# CombineInheritedObservation

[![Swift Version](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift Tests](https://github.com/inekipelov/combine-inherited-observation/actions/workflows/swift.yml/badge.svg)](https://github.com/inekipelov/combine-inherited-observation/actions/workflows/swift.yml)

A lightweight Swift library for hierarchical state management and change propagation in SwiftUI applications using Combine and the `ObservableObject` protocol.

## Overview

When building complex SwiftUI applications with multiple view models and a hierarchical state structure, propagating state changes through the hierarchy can be challenging. This library provides simple yet powerful extensions to `ObservableObject` that enable:

- **Inheritance**: Parent objects can inherit change notifications from child objects
- **Broadcasting**: Child objects can broadcast changes to parent objects

This enables efficient state synchronization without boilerplate code, keeping your SwiftUI views reactive and up-to-date.

## Requirements

- Swift 5.5+
- iOS 13.0+/ macOS 10.15+/ tvOS 13.0+/ watchOS 6.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/inekipelov/combine-inherited-observation.git", from: "0.2.0")
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
    private(set) var child: Child = Child()
}

// Get cancellable back directly
let inheritCancellable = parent.inherit(objectWillChange: \.child)
```

This creates a subscription where any changes to the `child` observable object will automatically trigger the parent's `objectWillChange` publisher. The returned `AnyCancellable` should be stored to maintain the subscription.

You can also inherit changes from individual objects directly:

```swift
let parent = Parent()
let child = Child()

// Parent will be notified of changes in child
let cancellable = parent.inherit(objectWillChange: child)

// Later, you can cancel the subscription
inheritCancellable.cancel()
```

### Array Support

The library also supports inheriting changes from arrays of observable objects:

```swift
class ParentOfManyChildren: ObservableObject {
    private(set) var children: [Child] = [Child(), Child()]
}
// Parent will be notified when any child in the array changes
let cancellable = parent.inherit(objectWillChange: \.children)
```

### Broadcast Changes from Child to Parent

An alternative approach is to have a child broadcast its changes to a parent:

```swift
class Child: ObservableObject {
    @Published private(set) var value: Int = 0
    
    func increment() {
        value += 1
    }
}

class Parent: ObservableObject {
    private(set) var child: Child = Child()
}

let cancellable = parent.child.broadcast(objectWillChange: parent)
```

### Collection Broadcasting

You can also broadcast changes from a collection of observable objects to a parent:

```swift
class ParentOfManyChildren: ObservableObject {
    private(set) var children: [Child] = [Child(), Child()]
}
let cancellable = parent.children.broadcast(objectWillChange: parent)
```

### Using Multiple Approaches

You can use both `inherit` and `broadcast` approaches depending on which pattern fits your application's architecture better:

```swift
// Inherit approach: Parent listens to child
let inheritCancellable = parent.inherit(objectWillChange: child)

// Broadcast approach: Child notifies parent
let broadcastCancellable = child.broadcast(objectWillChange: parent)
```

Both approaches achieve the same result but offer different conceptual models for managing your application's state flow.

## Available Methods

### Inheritance Methods

```swift
// Inherit from an observable object directly
func inherit<T: ObservableObject>(objectWillChange other: T) -> AnyCancellable

// Inherit from an observable object via key path
func inherit<T: ObservableObject>(objectWillChange keyPath: KeyPath<Self, T>) -> AnyCancellable

// Inherit from an array of observable objects
func inherit<T: ObservableObject>(objectWillChange others: [T]) -> AnyCancellable

// Inherit from multiple observable objects using variadic parameters
func inherit<T: ObservableObject>(objectWillChange others: T...) -> AnyCancellable

// Inherit from an array of observable objects via key path
func inherit<T: ObservableObject>(objectWillChange keyPath: KeyPath<Self, [T]>) -> AnyCancellable
```

### Broadcasting Methods

```swift
// Broadcast from a single observable object to another
func broadcast<T: ObservableObject>(objectWillChange other: T) -> AnyCancellable

// Broadcast from a collection of observable objects to another
Collection.broadcast<T: ObservableObject>(objectWillChange other: T) -> AnyCancellable
```

## Benefits

- **Cleaner Code**: No need for manual publisher management
- **Automatic Memory Management**: Uses weak references to avoid retain cycles
- **Flexible API**: Multiple functions to fit different use cases
- **SwiftUI Integration**: Works seamlessly with SwiftUI's reactive UI updates

## License

This library is released under the MIT License. See [LICENSE](LICENSE) for details.
