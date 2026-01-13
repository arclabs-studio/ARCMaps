import Foundation
@testable import ARCMaps

public final class MockLogger: LoggerProtocol, @unchecked Sendable {

    public private(set) var debugMessages: [String] = []
    public private(set) var infoMessages: [String] = []
    public private(set) var warningMessages: [String] = []
    public private(set) var errorMessages: [(String, Error?)] = []

    private let lock = NSLock()

    public init() {}

    public func debug(_ message: String) {
        lock.withLock { debugMessages.append(message) }
    }

    public func info(_ message: String) {
        lock.withLock { infoMessages.append(message) }
    }

    public func warning(_ message: String) {
        lock.withLock { warningMessages.append(message) }
    }

    public func error(_ message: String, error: Error?) {
        lock.withLock { errorMessages.append((message, error)) }
    }

    public func reset() {
        lock.withLock {
            debugMessages.removeAll()
            infoMessages.removeAll()
            warningMessages.removeAll()
            errorMessages.removeAll()
        }
    }
}
