//
//  CoreData+Operations.swift
//  BarChip
//
//  Created by Bibin on 16/10/20.
//  Copyright © 2020 Sijo Thomas. All rights reserved.
//

import CoreData

/// Class that handles Coredata Database
final class Database {
    
    /// Context of cordata. Confugre must be called before using this variable.
    private(set) static var context: NSManagedObjectContext! = nil
    
    /// Coredata persistant container
    static var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: Bundle.name)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)") }
        })
        return container
    }
    
    /// This prevents instatiation for this class
    private init() {}
}

extension Database {
    
    /// This configures the database. This MUST be called first.
    static func configure(completion: (() -> Void)? = nil) {
        enqueueUIStack {
            context = persistentContainer.viewContext
            completion?()
        }
    }
    
    static var privateContext: NSManagedObjectContext { persistentContainer.newBackgroundContext() }
    
    static func save(context: NSManagedObjectContext = context) {
        if context.hasChanges {
            do { try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

private extension Bundle {
    static var name: String { Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String }
}
