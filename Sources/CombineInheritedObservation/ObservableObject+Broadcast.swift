//
//  ObservableObject+Broadcast.swift
//  CombineInheritedObservation
//

import Foundation
import Combine

public extension ObservableObject {
    /// Broadcasts state change notifications from this observable object to another observable object.
    ///
    /// When the current object changes, this method ensures the other object's `objectWillChange` publisher
    /// is triggered, enabling automatic UI updates in SwiftUI for views observing that object.
    ///
    /// - Parameter other: The observable object that will be notified when this object changes
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func broadcast<T: ObservableObject>(
        objectWillChange other: T
    ) -> AnyCancellable where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        return objectWillChange
            .map { _ in }
            .sink { [weak other] in
                other?.objectWillChange.send()
            }
    }
    
    /// Broadcasts state change notifications from this observable object to another observable object
    /// and automatically stores the cancellable.
    ///
    /// This is a convenience method that both broadcasts changes to the other object and stores the resulting
    /// cancellable in the provided set.
    ///
    /// - Parameters:
    ///   - other: The observable object that will be notified when this object changes
    ///   - store: The set in which to store the resulting cancellable
    ///
    func broadcast<T: ObservableObject>(
        objectWillChange other: T,
        store: inout Set<AnyCancellable>
    ) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        broadcast(objectWillChange: other)
            .store(in: &store)
    }
}
