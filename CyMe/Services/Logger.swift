import Foundation

class Logger {
    static let shared = Logger()
    public let logFileURL: URL

    var logFilePath: URL {
        return logFileURL
    }

    private init() {
        let fileManager = FileManager.default
        let documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        logFileURL = documentsURL.appendingPathComponent("logfile.txt")
    }

    func log(_ message: String) {
        let timestamp = Date().formatted(date: .abbreviated, time: .standard)
        let logMessage = "[\(timestamp)] \(message)\n"
        appendToFile(logMessage)
    }

    private func appendToFile(_ message: String) {
        do {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: logFileURL)
                fileHandle.seekToEndOfFile()
                if let data = message.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try message.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to write to log file: \(error.localizedDescription)")
        }
    }
}
