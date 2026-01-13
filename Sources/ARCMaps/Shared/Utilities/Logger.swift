import Foundation
import os.log

/// Internal logging protocol
public protocol LoggerProtocol: Sendable {
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String, error: Error?)
}

/// Default logger implementation using OSLog
public final class DefaultLogger: LoggerProtocol, @unchecked Sendable {
    private let logger: os.Logger

    public init(subsystem: String = "com.arclabs.ARCMaps", category: String = "default") {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func debug(_ message: String) {
        logger.debug("\(message)")
    }

    public func info(_ message: String) {
        logger.info("\(message)")
    }

    public func warning(_ message: String) {
        logger.warning("\(message)")
    }

    public func error(_ message: String, error: Error? = nil) {
        if let error = error {
            logger.error("\(message): \(error.localizedDescription)")
        } else {
            logger.error("\(message)")
        }
    }
}
