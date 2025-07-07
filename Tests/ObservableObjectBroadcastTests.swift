import XCTest
import Combine
import SwiftUI
@testable import CombineObservationBroadcast

final class ObservableObjectBroadcastTests: XCTestCase {

    class Child: ObservableObject {
        @Published private(set) var value: Int = 0
        func increment() {
            value += 1
        }
    }
    class Parent: ObservableObject {
        private(set) var child: Child = Child()
    }
    class ParentOfManyChildren: ObservableObject {
        private(set) var children: [Child] = [Child(), Child()]
    }

    
    func testBroadcasting() {
        let sut = Parent()
        var sutChangesIndex = 0
        
        let broadcasting = sut.child.broadcast(objectWillChange: sut)
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangesIndex = $0 }
        
        sut.child.increment()
        
        XCTAssertEqual(sutChangesIndex, 1, "With broadcast, child changes should affect parent")
        
        cancellable.cancel()
        broadcasting.cancel()
    }
    func testWithoutBroadcasting() {
        let sut = Parent()
        var sutChangesIndex = 0
        
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangesIndex = $0 }
        
        sut.child.increment()
        
        XCTAssertEqual(sutChangesIndex, 0, "Without broadcast, child changes should NOT affect parent")
        
        cancellable.cancel()
    }
    
    func testBroadcastingArray() {
        let sut = ParentOfManyChildren()
        var sutChangesIndex = 0
        
        let broadcasting = sut.children.broadcast(objectWillChange: sut)
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangesIndex += $0 }
        
        sut.children.first?.increment()
        sut.children.last?.increment()
        
        XCTAssertEqual(sutChangesIndex, 2, "With broadcast, child changes should affect parent")

        cancellable.cancel()
        broadcasting.cancel()
    }
    
    func testWithoutBroadcastingArray() {
        let sut = ParentOfManyChildren()
        var sutChangesIndex = 0
        
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangesIndex += $0 }
        
        sut.children.first?.increment()
        sut.children.last?.increment()
        
        XCTAssertEqual(sutChangesIndex, 0, "Without broadcast, child changes should NOT affect parent")

        cancellable.cancel()
    }
}
