import Foundation

struct ChangeNotifications {
    private let query: NSMetadataQuery

    init(for directory: String, notificationBatchingInterval: TimeInterval = 1.0) {
        self.query = NSMetadataQuery()
        self.query.searchScopes = [directory]
        self.query.notificationBatchingInterval = notificationBatchingInterval
        self.query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "public.item")
    }

    func observe(
        using block: @escaping @Sendable () -> Void,
        to notificationCenter: NotificationCenter = NotificationCenter.default
    ) -> Observation {
        let finishGatheringObservation = notificationCenter.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: query, queue: .main, using: { _ in
            block()
        })
        let updateObservation = notificationCenter.addObserver(forName: .NSMetadataQueryDidUpdate, object: query, queue: .main, using: { _ in
            block()
        })
        return Observation(updateObservation, finishGatheringObservation)
    }

    func start() {
        query.start()
    }

    func stop() {
        query.stop()
    }

    class Observation {
        private let updateObservation: Any
        private let finishGatheringObservation: Any

        init(_ updateObservation: Any, _ finishGatheringObservartion: Any) {
            self.updateObservation = updateObservation
            self.finishGatheringObservation = finishGatheringObservartion
        }

        deinit {
            remove()
        }

        func remove(from notificationCenter: NotificationCenter = NotificationCenter.default) {
            notificationCenter.removeObserver(self.updateObservation)
            notificationCenter.removeObserver(self.finishGatheringObservation)
        }
    }
}
