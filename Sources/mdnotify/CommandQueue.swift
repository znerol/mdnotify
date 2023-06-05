import Foundation

enum CommandQueueError: Error {
    case nonZeroTerminationStatus(status: Int32)
}

@available(macOS 10.15.0, *)
actor CommandQueue {
    let command: [String]

    init(command: [String]) {
        self.command = command
    }

    func post() throws {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = command

        try proc.run()
        proc.waitUntilExit()

        if proc.terminationStatus != 0 {
            throw CommandQueueError.nonZeroTerminationStatus(status: proc.terminationStatus)
        }
    }
}
