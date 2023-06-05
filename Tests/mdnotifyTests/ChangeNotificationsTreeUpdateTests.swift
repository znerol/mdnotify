import XCTest
@testable import mdnotify

final class ChangeNotificationsTreeUpdateTests: XCTestCase {
    func testOneFileDirectoryTreeSubdirectoryRemoved() throws {
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

        let subdir = tmpdir.appendingPathComponent("testdir")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: false)
        try "hello world".write(to: subdir.appendingPathComponent("test.txt"), atomically: false, encoding: .utf8)

        wait(for: [secondInvocation], timeout: 5.0)

        try FileManager.default.removeItem(at: subdir)

        wait(for: [thirdInvocation], timeout: 5.0)
    }

    func testEmptyDirectoryTreeOneSubdirectoryAdded() throws {
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

        let subdir = tmpdir.appendingPathComponent("testdir")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: false)
        try "hello world".write(to: subdir.appendingPathComponent("test.txt"), atomically: false, encoding: .utf8)

        wait(for: [invocationCount], timeout: 5.0)
    }

    func testOneFileDirectoryTreeSubdirectoryMoved() throws {
        let invocation = XCTestExpectation(description: "Callback was invoked.")
        let invocationCount = XCTestExpectation(description: "Callback was invoked once.")
        invocationCount.expectedFulfillmentCount = 2
        invocationCount.assertForOverFulfill = true

        let tmpdir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("mdnotifyTest-\(UUID())")
        try FileManager.default.createDirectory(at: tmpdir, withIntermediateDirectories: false)
        defer {try! FileManager.default.removeItem(at: tmpdir) }

        let subdir = tmpdir.appendingPathComponent("testdir")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: false)
        try "hello world".write(to: subdir.appendingPathComponent("test.txt"), atomically: false, encoding: .utf8)

        let notifications = ChangeNotifications(for: tmpdir.path)
        let observation = notifications.observe(using: {
            invocation.fulfill()
            invocationCount.fulfill()
        })
        defer { observation.remove() }

        notifications.start()
        defer { notifications.stop() }

        wait(for: [invocation], timeout: 5.0)

        try FileManager.default.moveItem(at: subdir, to: tmpdir.appendingPathComponent("otherdir"))

        wait(for: [invocationCount], timeout: 5.0)
    }
}
