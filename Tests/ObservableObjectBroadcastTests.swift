import XCTest
import Combine
import SwiftUI
@testable import CombineInheritedObservation

final class ObservableObjectBroadcastTests: XCTestCase {

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
            
            child.broadcast(objectWillChange: self, store: &cancellables)
            children.broadcast(objectWillChange: self, store: &cancellables)
        }
    }
    
    func testBroadcasting() {
        let parent = Parent()
        var parentChanged = false
        
        let cancellable = parent.objectWillChange.sink { _ in
            parentChanged = true
        }
        
        parent.child.increment()
        
        XCTAssertTrue(parentChanged, "With broadcast, child changes should affect parent")
        
        cancellable.cancel()
    }
    
    func testBroadcastingArray() {
        let sut = Parent()
        var sutChangesIndex = 0
        
        let cancellable = sut.objectWillChange.sink { _ in
            sutChangesIndex += 1
        }
        
        sut.children.first?.increment()
        sut.children.last?.increment()
        
        XCTAssertEqual(sutChangesIndex, 2, "With broadcast, child changes should affect parent")

        cancellable.cancel()
    }
}
