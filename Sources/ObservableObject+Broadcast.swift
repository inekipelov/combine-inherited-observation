//
//  ObservableObject+Broadcast.swift
//  CombineObservationBroadcast
//

import Foundation
import Combine

public extension ObservableObject {
    /// Broadcasts state change notifications from this observable object to another observable object.
    ///
    /// When the current object changes, this method ensures the other object's `objectWillChange` publisher
    /// is triggered, enabling automatic UI updates in SwiftUI for views observing that object. This is useful
    /// for propagating changes from child objects to their parent objects.
    ///
    /// - Parameter other: The observable object that will be notified when this object changes
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    /// - Note: Uses a weak reference to avoid retain cycles
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
}

public extension Collection where Element: ObservableObject {
    /// Broadcasts state change notifications from all observable objects in the collection to another observable object.
    ///
    /// When any object in the collection changes, this method ensures the other object's `objectWillChange` publisher
    /// is triggered, enabling automatic UI updates in SwiftUI for views observing that object. This is particularly useful
    /// when handling collections of child objects that need to notify their parent.
    ///
    /// - Parameter other: The observable object that will be notified when any object in the collection changes
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    /// - Note: Uses a weak reference to avoid retain cycles and automatically merges all publishers from the collection
    ///
    func broadcast<T: ObservableObject>(
        objectWillChange other: T
    ) -> AnyCancellable where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        
        let publishers = map { $0.objectWillChange }
        return Publishers.MergeMany(publishers)
            .map { _ in }
            .sink { [weak other] in
                other?.objectWillChange.send()
            }
    }
}
