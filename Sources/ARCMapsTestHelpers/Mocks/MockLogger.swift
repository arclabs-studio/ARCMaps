import Foundation
@testable import ARCMaps

public actor MockLogger: LoggerProtocol {

    public private(set) var debugMessages: [String] = []
    public private(set) var infoMessages: [String] = []
    public private(set) var warningMessages: [String] = []
    public private(set) var errorMessages: [(String, Error?)] = []

    public init() {}

    public func debug(_ message: String) {
        debugMessages.append(message)
    }

    public func info(_ message: String) {
        infoMessages.append(message)
    }

    public func warning(_ message: String) {
        warningMessages.append(message)
    }

    public func error(_ message: String, error: Error?) {
        errorMessages.append((message, error))
    }

    public func reset() {
        debugMessages.removeAll()
        infoMessages.removeAll()
        warningMessages.removeAll()
        errorMessages.removeAll()
    }
}
