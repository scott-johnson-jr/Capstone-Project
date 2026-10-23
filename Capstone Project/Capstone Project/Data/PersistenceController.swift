//
//  PersistenceController.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//

internal import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // cannot proceed without Core Data
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    
}
