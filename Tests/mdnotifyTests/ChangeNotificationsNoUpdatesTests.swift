import XCTest
@testable import mdnotify

final class ChangeNotificationsNoUpdatesTests: XCTestCase {
    func testEmptyDirectoryNoUpdates() throws {
        let invocation = XCTestExpectation(description: "Callback was invoked.")
        let invocationCount = XCTestExpectation(description: "Callback was invoked once.")
        invocationCount.expectedFulfillmentCount = 1
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

        wait(for: [invocation, invocationCount], timeout: 5.0)
    }

    func testOneFileDirectoryNoUpdates() throws {
        let invocation = XCTestExpectation(description: "Callback was invoked.")
        let invocationCount = XCTestExpectation(description: "Callback was invoked once.")
        invocationCount.expectedFulfillmentCount = 1
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

        wait(for: [invocation, invocationCount], timeout: 5.0)
    }
}
