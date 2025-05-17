import XCTest
import Combine
import SwiftUI
@testable import CombineInheritedObservable

// Test cases for the inherit functionality
final class ObservableObjectInheritTests: XCTestCase {
    // Simple child view model
    class TestChildViewModel: ObservableObject {
        @Published var value: Int = 0
    }

    // Simple parent view model with a child
    class TestParentViewModel: ObservableObject {
        @Published var value: Int = 0
    }
    
    // Test showing the inherit functionality
    func testInheritance() {
        let parent = TestParentViewModel()
        let child = TestChildViewModel()
        var childChanged = false
        
        var cancellables = Set<AnyCancellable>()
        
        // Setup subscription to child changes
        child.objectWillChange
            .sink { _ in
                childChanged = true
            }
            .store(in: &cancellables)
        
        // Setup inheritance from parent
        child.inherit(objectWillChange: parent, store: &cancellables)
        
        // Change parent - should trigger child change
        parent.value += 1
        
        XCTAssertTrue(childChanged, "With inherit, parent changes should affect child")
    }
    
    // Test returning cancellable directly
    func testInheritWithManualCancellable() {
        let parent = TestParentViewModel()
        let child = TestChildViewModel()
        var childChanged = false
        
        // Setup subscription to child changes
        let subscription = child.objectWillChange
            .sink { _ in
                childChanged = true
            }
        
        // Setup inheritance from parent with explicit cancellable
        let inheritCancellable = child.inherit(objectWillChange: parent)
        
        // Change parent - should trigger child change
        parent.value += 1
        
        XCTAssertTrue(childChanged, "With inherit, parent changes should affect child")
        
        // Cleanup
        subscription.cancel()
        inheritCancellable.cancel()
    }
    
    // Test multiple inheritances
    func testMultipleInheritance() {
        let parentA = TestParentViewModel()
        let parentB = TestParentViewModel()
        let child = TestChildViewModel()
        var childChangeCount = 0
        
        var cancellables = Set<AnyCancellable>()
        
        // Setup subscription to child changes
        child.objectWillChange
            .sink { _ in
                childChangeCount += 1
            }
            .store(in: &cancellables)
        
        // Setup inheritance from both parents
        child.inherit(objectWillChange: parentA, store: &cancellables)
        child.inherit(objectWillChange: parentB, store: &cancellables)
        
        // Change both parents
        parentA.value += 1
        parentB.value += 1
        
        XCTAssertEqual(childChangeCount, 2, "Child should receive updates from both parents")
    }
}
