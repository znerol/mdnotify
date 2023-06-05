import XCTest
@testable import mdnotify

final class ChangeNotificationsFileUpdateTests: XCTestCase {
    func testOneFileDirectoryOneFileRemoved() throws {
        let firstInvocation = expectation(description: "First callback invocation.")
        let secondInvocation = expectation(description: "Second callback invocation.")
        let thirdInvocation = expectation(description: "Third callback invocation.")
        let invocations = Expectations(firstInvocation, secondInvocation, thirdInvocation)

        let tmpdir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("mdnotifyTest-\(UUID())")
        try FileManager.default.createDirectory(at: tmpdir, withIntermediateDirectories: false)
        defer {try! FileManager.default.removeItem(at: tmpdir) }

        let notifications = ChangeNotifications(for: tmpdir.path)
        let observation = notifications.observe(using: {
            Task { await invocations.removeFirst().fulfill() }
        })
        defer { observation.remove() }

        notifications.start()
        defer { notifications.stop() }

        wait(for: [firstInvocation], timeout: 5.0)

        try "hello world".write(to: tmpdir.appendingPathComponent("test.txt"), atomically: false, encoding: .utf8)

        wait(for: [secondInvocation], timeout: 5.0)

        try FileManager.default.removeItem(at: tmpdir.appendingPathComponent("test.txt"))

        wait(for: [thirdInvocation], timeout: 5.0)
    }

    func testEmptyDirectoryOneFileAdded() throws {
        let invocation = XCTestExpectation(description: "Callback was invoked.")
        let invocationCount = XCTestExpectation(description: "Callback was invoked twice.")
        invocationCount.expectedFulfillmentCount = 2
        invocationCount.assertForOverFulfill = true

        let tmpdir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("mdnotifyTest-\(UUID())")
        try FileManager.default.createDirectory(at: tmpdir, withIntermediateDirectories: false)
        defer {try! FileManager.default.removeItem(at: tmpdir) }

        let notifications = ChangeNotifications(for: tmpdir.path)
        let observation = notifications.observe(using: {
            invocation.fulfill()
            invocationCount.fulfill()
        })
        defer { observation.remove() }

        notifications.start()
        defer { notifications.stop() }

        wait(for: [invocation], timeout: 5.0)

        try "hello world".write(to: tmpdir.appendingPathComponent("test.txt"), atomically: false, encoding: .utf8)

        wait(for: [invocationCount], timeout: 5.0)
    }

    func testOneFileDirectoryOneFileMoved() throws {
        let invocation = XCTestExpectation(description: "Callback was invoked.")
        let invocationCount = XCTestExpectation(description: "Callback was invoked once.")
        invocationCount.expectedFulfillmentCount = 2
        invocationCount.assertForOverFulfill = true

        let tmpdir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("mdnotifyTest-\(UUID())")
        try FileManager.default.createDirectory(at: tmpdir, withIntermediateDirectories: false)
        defer {try! FileManager.default.removeItem(at: tmpdir) }

        try "hello world".write(to: tmpdir.appendingPathComponent("test.txt"), atomically: false, encoding: .utf8)

        let notifications = ChangeNotifications(for: tmpdir.path)
        let observation = notifications.observe(using: {
            invocation.fulfill()
            invocationCount.fulfill()
        })
        defer { observation.remove() }

        notifications.start()
        defer { notifications.stop() }

        wait(for: [invocation], timeout: 5.0)

        try FileManager.default.moveItem(at: tmpdir.appendingPathComponent("test.txt"), to: tmpdir.appendingPathComponent("other.txt"))

        wait(for: [invocationCount], timeout: 5.0)
    }
}
