//
//  TableItem.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//
import Foundation
import CoreData

struct TableItem: Codable, Equatable {
    let id: UUID
    var title: String
    var body: String?
    var date: Date = Date()
    var isCompleted: Bool
    let serverId: Int?
    var lastUpdated: Date = Date()
    
    static func == (lhs: TableItem, rhs: TableItem) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title = "todo"
        case isCompleted = "completed"
        case serverId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        serverId = try container.decode(Int.self, forKey: .serverId)
    }

    init(id: UUID = UUID(), title: String = "", body: String? = nil, isCompleted: Bool = false, serverId: Int? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.isCompleted = isCompleted
        self.serverId = serverId
    }

    init(entity: TaskEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.body = entity.body
        self.isCompleted = entity.completed
        self.date = entity.date ?? Date()
        self.serverId = entity.serverId != 0 ? Int(entity.serverId) : nil
    }

    func toEntity(in context: NSManagedObjectContext) -> TaskEntity {
        let entity = TaskEntity(context: context)
        entity.id = self.id
        entity.title = self.title
        entity.body = self.body
        entity.completed = self.isCompleted
        entity.date = self.date
        entity.serverId = self.serverId != nil ? Int32(self.serverId!) : 0
        return entity
    }
}
