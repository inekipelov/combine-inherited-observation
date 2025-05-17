import XCTest
import Combine
import SwiftUI
@testable import CombineInheritedObservable

// Test cases for the propagate functionality
final class ObservableObjectPropagateTests: XCTestCase {
    // Simple child view model
    class TestChildViewModel: ObservableObject {
        @Published var value: Int = 0
    }

    // Simple parent view model with a child
    class TestParentViewModel: ObservableObject {
        @Published var child: TestChildViewModel
        
        private var cancellables = Set<AnyCancellable>()
        
        init(autoPropagate: Bool = false) {
            self.child = TestChildViewModel()
            
            if autoPropagate {
                // Use our extension to bind changes from child to parent
                child.propagate(objectWillChange: self, store: &cancellables)
            }
        }
    }
    
    // Basic test showing the default behavior (without propagation)
    func testDefaultBehavior() {
        let parent = TestParentViewModel()
        var parentChanged = false
        
        let cancellable = parent.objectWillChange.sink { _ in
            parentChanged = true
        }
        
        // Change child - should NOT trigger parent change
        parent.child.value += 1
        
        XCTAssertFalse(parentChanged, "By default, child changes should not affect parent")
        
        // Cleanup
        cancellable.cancel()
    }
    
    // Test showing the propagate functionality
    func testPropagation() {
        let parent = TestParentViewModel(autoPropagate: true)
        var parentChanged = false
        
        let cancellable = parent.objectWillChange.sink { _ in
            parentChanged = true
        }
        
        // Change child - SHOULD trigger parent change
        parent.child.value += 1
        
        XCTAssertTrue(parentChanged, "With propagate, child changes should affect parent")
        
        // Cleanup
        cancellable.cancel()
    }
    
    // Test with manual propagation setup (not using constructor)
    func testManualPropagation() {
        let parent = TestParentViewModel()
        var parentChanged = false
        var cancellables = Set<AnyCancellable>()
        
        let cancellable = parent.objectWillChange.sink { _ in
            parentChanged = true
        }
        
        // Set up propagation manually
        parent.child.propagate(objectWillChange: parent, store: &cancellables)
        
        // Change child - SHOULD trigger parent change
        parent.child.value += 1
        
        XCTAssertTrue(parentChanged, "With manual propagate, child changes should affect parent")
        
        // Cleanup
        cancellable.cancel()
    }
}
