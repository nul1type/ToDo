//
//  CoreDataManager.swift
//  ToDo
//
//  Created by Анатолий Александрович on 25.07.2025.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    init(container: NSPersistentContainer? = nil) {
        if let container = container {
            persistentContainer = container
        } else {
            persistentContainer = NSPersistentContainer(name: "ToDo")
            persistentContainer.loadPersistentStores { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    private func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }
    
    // MARK: - Fetch
    func fetchTasks(completion: @escaping ([TableItem]) -> Void) {
        let context = newBackgroundContext()
        
        context.performAndWait {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            
            do {
                let results = try context.fetch(request)
                let items = results.map { TableItem(entity: $0) }
                DispatchQueue.main.async {
                    completion(items)
                }
            } catch {
                print("Fetch tasks error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func addTask(_ task: TableItem, completion: (() -> Void)? = nil) {
        let context = newBackgroundContext()
        
        context.performAndWait {
            let entity = TaskEntity(context: context)
            entity.id = task.id
            entity.title = task.title
            entity.body = task.body
            entity.completed = task.isCompleted
            entity.date = task.date
            entity.serverId = task.serverId != nil ? Int32(task.serverId!) : 0
            
            self.saveContext(context)
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func updateTask(_ task: TableItem, completion: (() -> Void)? = nil) {
        let context = newBackgroundContext()
        
        context.performAndWait {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                if let entity = try context.fetch(request).first {
                    entity.title = task.title
                    entity.body = task.body
                    entity.completed = task.isCompleted
                    entity.date = task.date
                    self.saveContext(context)
                }
            } catch {
                print("Update task error: \(error)")
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func deleteTask(_ task: TableItem, completion: (() -> Void)? = nil) {
        let context = newBackgroundContext()
        
        context.performAndWait {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            do {
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    self.saveContext(context)
                }
            } catch {
                print("Delete task error: \(error)")
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func syncWithNetwork(tasks: [TableItem], completion: @escaping () -> Void) {
        let context = newBackgroundContext()
        
        context.perform {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            guard let localTasks = try? context.fetch(request) else {
                completion()
                return
            }
            
            var localDict = [Int: TaskEntity]()
            localTasks.forEach {
                if $0.serverId != 0 {
                    localDict[Int($0.serverId)] = $0
                }
            }
            
            for serverTask in tasks {
                guard let serverId = serverTask.serverId else { continue }
                
                if let localEntity = localDict[serverId] {
                    if localEntity.lastUpdated < serverTask.lastUpdated {
                        localEntity.update(from: serverTask)
                    }
                } else {
                    let newEntity = TaskEntity(context: context)
                    newEntity.update(from: serverTask)
                }
            }
            
            let serverIds = tasks.compactMap { $0.serverId }
            for entity in localTasks {
                if entity.serverId != 0 && !serverIds.contains(Int(entity.serverId)) {
                    context.delete(entity)
                }
            }
            
            self.saveContext(context)
            completion()
        }
    }
}
