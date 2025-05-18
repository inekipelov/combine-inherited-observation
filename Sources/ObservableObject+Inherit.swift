//
//  ObservableObject+Inherit.swift
//  CombineInheritedObservation
//

import Foundation
import Combine

public extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    /// Inherits state change notifications from another observable object.
    ///
    /// When the other object changes, this method ensures the current object's `objectWillChange` publisher
    /// is triggered, allowing for automatic UI updates in SwiftUI.
    ///
    /// - Parameter other: The observable object whose changes will trigger the current object's `objectWillChange` publisher
    /// - Returns: An `AnyCancellable` instance that can be used to cancel the subscription
    ///
    func inherit<T: ObservableObject>(
        objectWillChange other: T
    ) -> AnyCancellable {
        return other.objectWillChange
            .map { _ in }
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
    }
    
    /// Inherits state change notifications from another observable object and automatically stores the cancellable.
    ///
    /// This is a convenience method that both inherits changes from the other object and stores the resulting
    /// cancellable in the provided set.
    ///
    /// - Parameters:
    ///   - other: The observable object whose changes will trigger the current object's `objectWillChange` publisher
    ///   - store: The set in which to store the resulting cancellable
    ///
    func inherit<T: ObservableObject>(
        objectWillChange other: T,
        store: inout Set<AnyCancellable>
    ) {
        inherit(objectWillChange: other)
            .store(in: &store)
    }
    
    /// Inherits state change notifications from an array of observable objects.
    ///
    /// When any of the objects in the array changes, this method ensures the current object's `objectWillChange` publisher
    /// is triggered, allowing for automatic UI updates in SwiftUI.
    ///
    /// - Parameter others: Array of observable objects whose changes will trigger the current object's `objectWillChange` publisher
    /// - Returns: An `AnyCancellable` instance that can be used to cancel all subscriptions
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
    
    func inherit<T: ObservableObject>(
        objectWillChange others: T...
    ) -> AnyCancellable {
        return inherit(objectWillChange: others)
    }
    
    /// Inherits state change notifications from an array of observable objects and automatically stores the cancellables.
    ///
    /// This is a convenience method that both inherits changes from the array of objects and stores the resulting
    /// cancellables in the provided set.
    ///
    /// - Parameters:
    ///   - others: Array of observable objects whose changes will trigger the current object's `objectWillChange` publisher
    ///   - store: The set in which to store the resulting cancellables
    ///
    func inherit<T: ObservableObject>(
        objectWillChange others: [T],
        store: inout Set<AnyCancellable>
    ) {
        inherit(objectWillChange: others)
            .store(in: &store)
    }
    
    func inherit<T: ObservableObject>(
        objectWillChange others: T...,
        store: inout Set<AnyCancellable>
    ) {
        inherit(objectWillChange: others, store: &store)
    }
}
