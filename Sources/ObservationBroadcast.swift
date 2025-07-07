//
//  ObservationBroadcast.swift
//  CombineObservationBroadcast
//

import Foundation
import Combine

/// A wrapper structure that automatically manages broadcasting from a wrapped ObservableObject to an owner.
///
/// This wrapper provides transparent access to the wrapped object's properties via @dynamicMemberLookup
/// while automatically managing the subscription that broadcasts changes from the wrapped object to the owner.
/// When the wrapped content is reassigned, the subscription is automatically recreated.
///
@dynamicMemberLookup
public struct ObservationBroadcast<Value: ObservableObject, Owner: ObservableObject>
where Owner.ObjectWillChangePublisher == ObservableObjectPublisher {
    
    private unowned var owner: Owner
    private var subscription: AnyCancellable?
    
    private var _value: Value {
        didSet {
            setupSubscription()
        }
    }
    
    /// Initializes the wrapper with an owner and content object
    ///
    /// - Parameters:
    ///   - owner: The observable object that will receive change notifications
    ///   - value: The observable object to wrap and monitor for changes
    public init(_ value: Value, to owner: Owner) {
        self.owner = owner
        self._value = value
        self.setupSubscription()
    }
    
    /// Dynamic member lookup to provide transparent access to wrapped object's properties
    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        _value[keyPath: keyPath]
    }
    
    /// Dynamic member lookup for writable properties
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get { _value[keyPath: keyPath] }
        set { _value[keyPath: keyPath] = newValue }
    }
}

private extension ObservationBroadcast {
    /// Sets up the subscription to broadcast changes from content to owner
    mutating func setupSubscription() {
        subscription?.cancel()
        subscription = _value.broadcast(objectWillChange: owner)
    }
}

// MARK: - Convenience Extensions

public extension ObservationBroadcast {
    func callAsFunction() -> Value {
        _value
    }
    
    @discardableResult
    mutating func callAsFunction(assign newValue: Value) -> Value {
        _value = newValue
        // setupSubscription() is called automatically via didSet
        return _value
    }
}

// MARK: - Collection Support

public extension ObservationBroadcast where Value: Collection {
    /// Provides subscript access for collection content
    subscript(index: Value.Index) -> Value.Element {
        get { _value[index] }
    }
}

public extension ObservationBroadcast where Value: MutableCollection {
    /// Provides mutable subscript access for mutable collection content
    subscript(index: Value.Index) -> Value.Element {
        get { _value[index] }
        set { _value[index] = newValue }
    }
}
