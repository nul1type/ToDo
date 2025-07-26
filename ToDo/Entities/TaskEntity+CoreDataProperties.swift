//
//  TaskEntity+CoreDataProperties.swift
//  ToDo
//
//  Created by Анатолий Александрович on 25.07.2025.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var body: String?
    @NSManaged public var completed: Bool
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var lastUpdated: Date
    @NSManaged public var serverId: Int32
    @NSManaged public var title: String?

}

extension TaskEntity : Identifiable {

}

extension TaskEntity {
    func update(from item: TableItem) {
        self.id = item.id
        self.title = item.title
        self.body = item.body
        self.completed = item.isCompleted
        self.date = item.date
        self.serverId = item.serverId != nil ? Int32(item.serverId!) : 0
        self.lastUpdated = item.lastUpdated
    }
}
