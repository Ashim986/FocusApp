import Foundation

public protocol AppStorage {
    func load() -> AppData
    func save(_ data: AppData)
}

public struct FileAppStorage: AppStorage {
    private let fileURL: URL

    public init(fileURL: URL = Self.defaultFileURL) {
        self.fileURL = fileURL
    }

    public func load() -> AppData {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return AppData()
        }

        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(AppData.self, from: jsonData)
        } catch {
            print("FileAppStorage: Failed to load data: \(error)")
            return AppData()
        }
    }

    public func save(_ data: AppData) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL)
        } catch {
            print("FileAppStorage: Failed to save data: \(error)")
        }
    }

    public static var defaultFileURL: URL {
        #if os(macOS)
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".dsa-focus-data.json")
        #else
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return directory.appendingPathComponent("dsa-focus-data.json")
        #endif
    }
}

public final class InMemoryAppStorage: AppStorage {
    private var stored: AppData

    public init(initial: AppData = AppData()) {
        self.stored = initial
    }

    public func load() -> AppData {
        stored
    }

    public func save(_ data: AppData) {
        stored = data
    }
}
