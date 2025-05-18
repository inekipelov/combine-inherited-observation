import XCTest
import Combine
import SwiftUI
@testable import CombineInheritedObservation

// Test cases for the broadcast functionality
final class ObservableObjectBroadcastTests: XCTestCase {
    // Simple child view model
    class TestChildViewModel: ObservableObject {
        @Published var value: Int = 0
    }

    // Simple parent view model with a child
    class TestParentViewModel: ObservableObject {
        @Published var child: TestChildViewModel
        
        private var cancellables = Set<AnyCancellable>()
        
        init(autoBroadcast: Bool = false) {
            self.child = TestChildViewModel()
            
            if autoBroadcast {
                // Use our extension to bind changes from child to parent
                child.broadcast(objectWillChange: self, store: &cancellables)
            }
        }
    }
    
    // Basic test showing the default behavior (without broadcasting)
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
    
    // Test showing the broadcast functionality
    func testBroadcasting() {
        let parent = TestParentViewModel(autoBroadcast: true)
        var parentChanged = false
        
        let cancellable = parent.objectWillChange.sink { _ in
            parentChanged = true
        }
        
        // Change child - SHOULD trigger parent change
        parent.child.value += 1
        
        XCTAssertTrue(parentChanged, "With broadcast, child changes should affect parent")
        
        // Cleanup
        cancellable.cancel()
    }
    
    // Test with manual broadcast setup (not using constructor)
    func testManualBroadcasting() {
        let parent = TestParentViewModel()
        var parentChanged = false
        var cancellables = Set<AnyCancellable>()
        
        let cancellable = parent.objectWillChange.sink { _ in
            parentChanged = true
        }
        
        // Set up broadcasting manually
        parent.child.broadcast(objectWillChange: parent, store: &cancellables)
        
        // Change child - SHOULD trigger parent change
        parent.child.value += 1
        
        XCTAssertTrue(parentChanged, "With manual broadcast, child changes should affect parent")
        
        // Cleanup
        cancellable.cancel()
    }
}
