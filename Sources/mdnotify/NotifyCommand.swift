import ArgumentParser
import Foundation

@main
@available(macOS 10.15.0, *)
struct NotifyCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "mdnotify",
        abstract: "Watches a directory recursively.",
        discussion: """
            Runs forever, or until mdnotify is terminated. Whenever a filesystem object is changed at any level inside the watched directory tree, the given command is invoked.
            """)

    @Option(name: .shortAndLong, help: "The interval at which a change notification occurs in seconds.")
    var interval: TimeInterval = 1.0

    @Argument(help: "The directory to watch.", completion: .directory)
    var directory: String

    @Argument(help: "The command to execute. (default: echo <directory>)")
    var command: [String] = []

    func validate() throws {
        let directoryUrl = URL(fileURLWithPath: directory)
        let fileWrapper = try? FileWrapper(url: directoryUrl)
        guard fileWrapper?.isDirectory == true else {
            throw ValidationError("No such directory or no access to specified directory.")
        }
    }

    mutating public func run() throws {
        let commandQueue = CommandQueue(command: command.isEmpty ? ["echo", directory] : command)

        let notifications = ChangeNotifications(for: directory, notificationBatchingInterval: interval)
        let observation = notifications.observe(using: {
            Task {
                do {
                    try await commandQueue.post()
                } catch {
                    NotifyCommand.exit(withError: error)
                }
            }
        })
        defer { observation.remove() }

        notifications.start()
        defer { notifications.stop() }

        RunLoop.main.run()
    }
}
