import XCTest
import Combine
import SwiftUI
@testable import CombineInheritedObservation

final class ObservableObjectInheritTests: XCTestCase {
    
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
    
    func testObservableInheritance() {
        let sut = Parent()
        var sutChangedIndex = 0
        
        let inheritance = sut.inherit(objectWillChange: \.child)
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangedIndex += $0 }
        
        sut.child.increment()
        
        XCTAssertEqual(sutChangedIndex, 1, "With inherit, child changes should affect parent")
        cancellable.cancel()
        inheritance.cancel()
    }
    
    func testObservableWithoutInheritance() {
        let sut = Parent()
        var sutChangedIndex = 0
        
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangedIndex += $0 }
        
        sut.child.increment()
        
        XCTAssertEqual(sutChangedIndex, 0, "Without inherit, child changes should NOT affect parent")
        cancellable.cancel()
    }
    
    func testObservableArrayInheritance() {
        let sut = ParentOfManyChildren()
        var sutChangedIndex = 0
        
        let inheritance = sut.inherit(objectWillChange: \.children)
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangedIndex += $0 }
        
        sut.children.first?.increment()
        sut.children.last?.increment()
        
        XCTAssertEqual(sutChangedIndex, 2, "With inherit, children changes should affect parent")
        cancellable.cancel()
        inheritance.cancel()
    }
    
    func testObservableArrayWithoutInheritance() {
        let sut = ParentOfManyChildren()
        var sutChangedIndex = 0
        
        let cancellable = sut.objectWillChange
            .map { 1 }
            .sink { sutChangedIndex += $0 }
        
        sut.children.first?.increment()
        sut.children.last?.increment()
        
        XCTAssertEqual(sutChangedIndex, 0, "Without inherit, children changes should NOT affect parent")
        cancellable.cancel()
    }
}
