import XCTest
import Combine

@testable import CombineObservationBroadcast

final class ObservationBroadcastTests: XCTestCase {
    
    class TestChild: ObservableObject {
        @Published var count: Int = 0
        
        func increment() {
            count += 1
        }
    }
    
    class TestParent: ObservableObject {
        private(set) lazy var child = ObservationBroadcast<TestChild, TestParent>(
            TestChild(), to: self
        )
    }
    
    // MARK: - Basic Functionality Tests
    
    func testChildChangesTriggersParentObjectWillChange() {
        let parent = TestParent()
        
        var parentChangeCount = 0
        
        let cancellable = parent.objectWillChange
            .sink { parentChangeCount += 1 }
        
        
        parent.child().increment()
        parent.child().increment()
        parent.child().increment()
        parent.child().increment()
        parent.child().increment()
        parent.child().increment()
        
        let expectation = XCTestExpectation(description: "Parent objectWillChange triggered")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(parentChangeCount, 6, "Parent should receive objectWillChange when child changes multiple times")
        XCTAssertEqual(parent.child().count, parentChangeCount, "Child count should match parent change count")
        
        cancellable.cancel()
    }

    
}
