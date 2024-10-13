//
//  CoreDataManager.swift
//  Millie
//
//  Created by 현은백 on 10/13/24.
//

import CoreData

final class CoreDataManager {
    // MARK: - Singleton
    static let shared = CoreDataManager()
    
    // MARK: - Core Data Stack
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ArticleModel")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Contexts
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Generic CRUD Operations
    
    func deleteAll<T: NSManagedObject>(_ entityType: T.Type) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try mainContext.execute(deleteRequest)
        } catch {
            print("기존 \(T.entity().name ?? "엔터티") 삭제 오류: \(error)")
        }
    }
    
    func save<T: NSManagedObject>(_ entity: T) {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                print("\(T.entity().name ?? "엔터티") 저장 오류: \(error)")
            }
        }
    }
    
    func save<T: NSManagedObject>(_ entities: [T]) {
        for entity in entities {
            mainContext.insert(entity)
        }
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                print("엔터티들 저장 오류: \(error)")
            }
        }
    }
    
    func fetchAll<T: NSManagedObject>(_ entityType: T.Type,
                                      predicate: NSPredicate? = nil,
                                      sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let results = try mainContext.fetch(fetchRequest) as? [T]
            return results ?? []
        } catch {
            print("\(T.entity().name ?? "엔터티") 페치 오류: \(error)")
            return []
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
