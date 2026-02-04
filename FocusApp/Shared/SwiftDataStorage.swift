import Foundation
import SwiftData

@Model
final class AppDataRecord {
    @Attribute(.unique) var id: UUID
    var payload: Data

    init(id: UUID = UUID(), payload: Data) {
        self.id = id
        self.payload = payload
    }
}

struct SwiftDataAppStorage: AppStorage {
    private let context: ModelContext
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }

    func load() -> AppData {
        var descriptor = FetchDescriptor<AppDataRecord>()
        descriptor.fetchLimit = 1
        do {
            if let record = try context.fetch(descriptor).first {
                if let decoded = try? decoder.decode(AppData.self, from: record.payload) {
                    return decoded
                }
            }
        } catch {
            print("SwiftDataAppStorage: Failed to load data: \(error)")
        }

        let fresh = AppData()
        persist(fresh)
        return fresh
    }

    func save(_ data: AppData) {
        persist(data)
    }

    private func persist(_ data: AppData) {
        do {
            let encoded = try encoder.encode(data)
            var descriptor = FetchDescriptor<AppDataRecord>()
            descriptor.fetchLimit = 1
            if let record = try context.fetch(descriptor).first {
                record.payload = encoded
            } else {
                context.insert(AppDataRecord(payload: encoded))
            }
            try context.save()
        } catch {
            print("SwiftDataAppStorage: Failed to save data: \(error)")
        }
    }
}
