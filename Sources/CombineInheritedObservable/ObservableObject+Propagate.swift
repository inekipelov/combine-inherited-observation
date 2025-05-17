//
//  ObservableObject+Propagate.swift
//  CombineInheritedObservable
//

import Foundation
import Combine

/// Extension for ObservableObject that provides functionality for propagating state changes to parent observable objects.
///
/// This extension enables upstream propagation of state changes in a hierarchical object structure,
/// allowing child objects to notify parent objects of their changes.
public extension ObservableObject {
    /// Propagates state change notifications from this observable object to a parent observable object.
    ///
    /// When the current object changes, this method ensures the parent object's `objectWillChange` publisher
    /// is triggered, enabling automatic UI updates in SwiftUI for views observing the parent.
    ///
    /// - Parameter parent: The parent observable object that will be notified when this object changes
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func propagate<T: ObservableObject>(
        objectWillChange parent: T
    ) -> AnyCancellable where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        return objectWillChange
            .map { _ in }
            .sink { [weak parent] in
                parent?.objectWillChange.send()
            }
    }
    
    /// Propagates state change notifications from this observable object to a parent observable object
    /// and automatically stores the cancellable.
    ///
    /// This is a convenience method that both propagates changes to the parent and stores the resulting
    /// cancellable in the provided set.
    ///
    /// - Parameters:
    ///   - parent: The parent observable object that will be notified when this object changes
    ///   - store: The set in which to store the resulting cancellable
    ///
    func propagate<T: ObservableObject>(
        objectWillChange parent: T,
        store: inout Set<AnyCancellable>
    ) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        propagate(objectWillChange: parent)
            .store(in: &store)
    }
}
