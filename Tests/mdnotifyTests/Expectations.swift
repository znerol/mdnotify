import XCTest

actor Expectations {
    var expectations: [XCTestExpectation]

    init (_ expectations: XCTestExpectation...) {
        self.expectations = expectations
    }

    func removeFirst() -> XCTestExpectation {
        return expectations.removeFirst()
    }
}
