//
//  ObservableObject+Inherit.swift
//  CombineObservationBroadcast
//

import Foundation
import Combine

public extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    
    /// Inherits state change notifications from any non-failable publisher.
    ///
    /// When the provided publisher emits a value, this method ensures the current object's `objectWillChange` publisher
    /// is triggered, allowing for automatic UI updates in SwiftUI views that observe this object.
    ///
    /// - Parameter publisher: Any publisher with a non-failable failure type whose emissions will trigger the current object's `objectWillChange` publisher
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func inherit<T: Publisher>(
        publisher: T
    ) -> AnyCancellable where T.Failure == Never {
        return publisher
            .map { _ in }
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
    }
    
    /// Inherits state change notifications from a publisher accessed via key path.
    ///
    /// When the publisher at the specified key path emits a value, this method ensures the current object's `objectWillChange`
    /// publisher is triggered, allowing for automatic UI updates in SwiftUI views that observe this object.
    ///
    /// - Parameter keyPath: A key path to a publisher property within this object
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func inherit<T: Publisher>(
        publisher keyPath: KeyPath<Self, T>
    ) -> AnyCancellable where T.Failure == Never {
        let publisher = self[keyPath: keyPath]
        return self.inherit(publisher: publisher)
    }
    
    /// Inherits state change notifications from another observable object.
    ///
    /// When the other object changes, this method ensures the current object's `objectWillChange` publisher
    /// is triggered, allowing for automatic UI updates in SwiftUI views that observe this object.
    ///
    /// - Parameter other: The observable object whose changes will trigger the current object's `objectWillChange` publisher
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func inherit<T: ObservableObject>(
        objectWillChange other: T
    ) -> AnyCancellable {
        return inherit(publisher: other.objectWillChange)
    }
    
    /// Inherits state change notifications from an observable object accessed via key path.
    ///
    /// When the observable object at the specified key path changes, this method ensures the current object's `objectWillChange`
    /// publisher is triggered, allowing for automatic UI updates in SwiftUI views that observe this object.
    ///
    /// - Parameter keyPath: A key path to an observable object property within this object
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func inherit<T: ObservableObject>(
        objectWillChange keyPath: KeyPath<Self, T>
    ) -> AnyCancellable {
        let object = self[keyPath: keyPath]
        return self.inherit(objectWillChange: object)
    }
    
    /// Inherits state change notifications from an array of observable objects.
    ///
    /// When any of the objects in the array changes, this method ensures the current object's `objectWillChange` publisher
    /// is triggered, allowing for automatic UI updates in SwiftUI views that observe this object.
    ///
    /// - Parameter others: Array of observable objects whose changes will trigger the current object's `objectWillChange` publisher
    /// - Returns: An `AnyCancellable` instance that can be used to cancel all subscriptions
    /// - Note: Returns an empty `AnyCancellable` if the array is empty
    ///
    func inherit<T: ObservableObject>(
        objectWillChange others: [T]
    ) -> AnyCancellable {
        guard !others.isEmpty else {
            return AnyCancellable {}
        }
        
        let publishers = others.map { $0.objectWillChange }
        return Publishers.MergeMany(publishers)
            .map { _ in }
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
    }
    
    /// Inherits state change notifications from multiple observable objects using variadic parameters.
    ///
    /// When any of the provided objects changes, this method ensures the current object's `objectWillChange` publisher
    /// is triggered, allowing for automatic UI updates in SwiftUI views that observe this object.
    ///
    /// - Parameter others: Variable number of observable objects whose changes will trigger the current object's `objectWillChange` publisher
    /// - Returns: An `AnyCancellable` instance that can be used to cancel all subscriptions
    ///
    func inherit<T: ObservableObject>(
        objectWillChange others: T...
    ) -> AnyCancellable {
        return inherit(objectWillChange: others)
    }
    
    /// Inherits state change notifications from an array of observable objects accessed via key path.
    ///
    /// When any of the observable objects in the array at the specified key path changes, this method ensures
    /// the current object's `objectWillChange` publisher is triggered, allowing for automatic UI updates
    /// in SwiftUI views that observe this object.
    ///
    /// - Parameter keyPath: A key path to an array of observable objects property within this object
    /// - Returns: An `AnyCancellable` instance that can be used to cancel all subscriptions
    ///
    func inherit<T: ObservableObject>(
        objectWillChange keyPath: KeyPath<Self, [T]>
    ) -> AnyCancellable {
        let others = self[keyPath: keyPath]
        return inherit(objectWillChange: others)
    }
}
