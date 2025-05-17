//
//  ObservableObject+Inherit.swift
//  CombineInheritedObservable
//

import Foundation
import Combine

/// Extension for ObservableObject that provides functionality for inheriting state changes from parent observable objects.
///
/// This extension enables downstream propagation of state changes in a hierarchical object structure,
/// allowing child objects to react to parent object changes.
public extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    /// Inherits state change notifications from a parent observable object.
    ///
    /// When the parent object changes, this method ensures the current object's `objectWillChange` publisher
    /// is triggered, allowing for automatic UI updates in SwiftUI.
    ///
    /// - Parameter parent: The parent observable object whose changes will trigger the current object's `objectWillChange` publisher
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func inherit<T: ObservableObject>(
        objectWillChange parent: T
    ) -> AnyCancellable {
        return parent.objectWillChange
            .map { _ in }
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
    }
    
    /// Inherits state change notifications from a parent observable object and automatically stores the cancellable.
    ///
    /// This is a convenience method that both inherits changes from the parent and stores the resulting
    /// cancellable in the provided set.
    ///
    /// - Parameters:
    ///   - parent: The parent observable object whose changes will trigger the current object's `objectWillChange` publisher
    ///   - store: The set in which to store the resulting cancellable
    ///
    func inherit<T: ObservableObject>(
        objectWillChange parent: T,
        store: inout Set<AnyCancellable>
    ) {
        inherit(objectWillChange: parent)
            .store(in: &store)
    }
}
