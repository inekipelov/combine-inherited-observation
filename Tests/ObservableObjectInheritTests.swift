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
        private(set) var child: Child
        private(set) var children: [Child]
         
        private var cancellables = Set<AnyCancellable>()
        
        init() {
            self.child = Child()
            self.children = [Child(), Child()]
                        
            self.inherit(objectWillChange: \.child, store: &cancellables)
            self.inherit(objectWillChange: \.children, store: &cancellables)
        }
    }
    
    func testObservableInheritance() {
        let sut = Parent()
        var sutChangedIndex = 0
        
        let cancellable = sut.objectWillChange
            .sink { _ in
                sutChangedIndex += 1
            }
        
        sut.child.increment()
        
        XCTAssertEqual(sutChangedIndex, 1, "With inherit, child changes should affect parent")
        cancellable.cancel()
    }
    
    func testObservableArrayInheritance() {
        let sut = Parent()
        var sutChangedIndex = 0
        
        let cancellable = sut.objectWillChange
            .sink { _ in
                sutChangedIndex += 1
            }
        
        sut.children.first?.increment()
        sut.children.last?.increment()
        
        XCTAssertEqual(sutChangedIndex, 2, "With inherit, children changes should affect parent")
        cancellable.cancel()
    }
}
