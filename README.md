# CombineObservationBroadcast

[![Swift Version](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift Tests](https://github.com/inekipelov/combine-observation-broadcast/actions/workflows/swift.yml/badge.svg)](https://github.com/inekipelov/combine-observation-broadcast/actions/workflows/swift.yml)  
[![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/macOS-10.15+-white.svg)](https://developer.apple.com/macos/)
[![tvOS](https://img.shields.io/badge/tvOS-13.0+-black.svg)](https://developer.apple.com/tvos/)
[![watchOS](https://img.shields.io/badge/watchOS-6.0+-orange.svg)](https://developer.apple.com/watchos/)

A lightweight Swift library for hierarchical state management and change propagation in SwiftUI applications using Combine and the `ObservableObject` protocol.

## Usage

```swift

class Child: ObservableObject {
    @Published var count: Int = 0
    
    func increment() {
        count += 1
    }
}
    
class Parent: ObservableObject {
    private(set) lazy var child = ObservationBroadcast<Child, Parent>(
        TestChild(), to: self
    )
}

let parent = Parent()
var isChanged = false
let cancellable = parent.objectWillChange
    .sink { isChanged = true }
    
parent.child().increment()
parent.child().increment()

print(parent.child().count) // Printed "2"
print(isChanged) // Printed "true"

```

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/inekipelov/combine-observation-broadcast.git", from: "0.3.0")
]
```

Or add it directly in Xcode using File → Swift Packages → Add Package Dependency...

## License

This library is released under the MIT License. See [LICENSE](LICENSE) for details.
