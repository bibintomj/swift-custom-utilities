//
//  CoreData+Extensions.swift
//  BarChip
//
//  Created by Bibin on 16/10/20.
//  Copyright © 2020 Sijo Thomas. All rights reserved.
//

import UIKit
import CoreData

/// Basic operations for coredata objects.
protocol CoreDataBasicOperable {}

/// Default implementation only iff NSManagedObject.
extension CoreDataBasicOperable where Self: NSManagedObject {
    
    /// A Search function using given predicate.
    ///
    /// Predicate varities
    ///
    /// let predicate1 = \PerformanceConfig.unit == "imperial"
    /// let predicate2 = \PerformanceConfig.calculatorTypeId == 1 && \PerformanceConfig.unit == "imperial"
    /// let predicate3 = \PerformanceConfig.calculatorTypeId == 1 || \PerformanceConfig.calculatorTypeId == 2
    /// let predicate4 = !(\PerformanceConfig.unit == "imperial")
    ///
    /// - Parameters:
    ///     - context       : Context to fetch data from.
    ///     - predicate     : Predicate to match and fetch from table. If nil, will fetch all data.
    ///     - completion    : Asyncronous completion with fetched items.
    static func fetch(from context: NSManagedObjectContext = Database.context,
                      matching predicate: NSPredicate? = nil,
                      completion: (([Self]?) -> Void)?) {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.predicate = predicate
        enqueueUIStack {
            
            do {
                let objects = try context.fetch(fetchRequest)
                completion?(objects)
            } catch {
                print("There was an error while searching in Coredata \(String(describing: Self.self))\n\(error.localizedDescription)")
                completion?(nil)
            }
        }
    }
    
    static func fetch(properties: [PartialKeyPath<Self>],
                    from context: NSManagedObjectContext = Database.context,
                      matching predicate: NSPredicate? = nil,
                      completion: (([NSDictionary]?) -> Void)?) {
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = properties.compactMap { $0._kvcKeyPathString }
        enqueueUIStack {
            
            do {
                let objects = try context.fetch(fetchRequest)
                completion?(objects)
            } catch {
                print("There was an error while searching in Coredata \(String(describing: Self.self))\n\(error.localizedDescription)")
                completion?(nil)
            }
        }
    }
    
    
    /// Delete items match the given predicate.
    /// - Parameters:
    ///     - predicate     : Predicate to match and delete from table.
    ///     - completion    : Async completion with delete status.
    static func delete(from context: NSManagedObjectContext = Database.context,
                       matching predicate: NSPredicate,
                       completion: ((Bool) -> Void)?) {
        
        let fetchRequest = Self.fetchRequest()
        fetchRequest.predicate = predicate
        
        enqueueUIStack {
            do {
                let objects = try context.fetch(fetchRequest) as? [Self] ?? []
                for object in objects {
                    context.delete(object)
                }
                Database.save(context: context)
                completion?(true)
            } catch {
                print("There was an error while deleting from Coredata \(String(describing: Self.self))\n\(error.localizedDescription)")
                completion?(false)
            }
        }
    }
    
    /// Deletes all the items in Table.
    /// - Parameters:
    ///     - predicate     : Predicate to match and delete from database.
    ///     - completion    : Async completion with delete status.
    static func truncate(from context: NSManagedObjectContext = Database.context,
                         commit: Bool = true,
                         completion: ((Bool) -> Void)?) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Self.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        enqueueUIStack {
            
            do {
                try context.execute(deleteRequest)
                commit ? Database.save(context: context) : ()
                completion?(true)
            } catch {
                print("There was an error while truncating Coredata \(String(describing: Self.self))\n\(error.localizedDescription)")
                completion?(false)
            }
        }
    }
    
    /// Returns a new row of class type for insertion.
    static func newRow(in context: NSManagedObjectContext = Database.context) -> Self {
        let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)
        return NSManagedObject(entity: entity!, insertInto: context) as! Self
    }
}

extension NSManagedObject: CoreDataBasicOperable {}

private extension NSManagedObject {
    /// Returns the name of the entity/table.
    static var entityName: String { return String(describing: self) }
}

extension CalculatorTypeConfig {
    static func insert(_ items: [Lookup.CalculatorTypeElement],
                       truncateExisting: Bool = false,
                       commit: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        let privateMOC = Database.privateContext
        let insert = {
            items.forEach {
                let new = newRow(in: privateMOC)
                new.id = Int64($0.id)
                new.type = $0.type
                commit ? Database.save(context: privateMOC) : ()
            }
            completion?(true)
        }
        
        guard truncateExisting else {
            insert()
            return
        }
        truncate(from: privateMOC, commit: commit) { _ in insert() }
    }
}

extension FiberTypeConfig {
    static func insert(_ items: [Lookup.FibreTypeElement],
                       truncateExisting: Bool = false,
                       commit: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        let privateMOC = Database.privateContext
        let insert = {
            items.forEach {
                let new = newRow(in: privateMOC)
                new.id = Int64($0.id)
                new.type = $0.type
                commit ? Database.save(context: privateMOC) : ()
            }
            completion?(true)
        }
        guard truncateExisting else {
            insert()
            return
        }
        truncate(from: privateMOC, commit: commit) { _ in insert() }
    }
}

extension MeshDiameterConfig {
    static func insert(_ items: [Lookup.MeshDiameter],
                       truncateExisting: Bool = false,
                       commit: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        let privateMOC = Database.privateContext

        let insert = {
            items.forEach {
                let new = newRow(in: privateMOC)
                new.mesh = $0.mesh
                new.diameter = $0.diameter
                commit ? Database.save(context: privateMOC) : ()
            }
            completion?(true)
        }
        guard truncateExisting else {
            insert()
            return
        }
        truncate(from: privateMOC, commit: commit) { _ in insert() }
    }
}

extension PerformanceConfig {
    static func insert(_ items: [Lookup.Performance],
                       truncateExisting: Bool = false,
                       commit: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        let privateMOC = Database.privateContext

        let insert = {
            items.forEach { performanceItem in
                [performanceItem.imperial, performanceItem.metric].enumerated().forEach { (index, item) in
                    item.forEach { measure in
                        let new = newRow(in: privateMOC)
                        new.calculatorTypeId = Int64(performanceItem.calculatorTypeID)
                        new.fibreTypeID = Int64(measure.fibreTypeID)
                        new.fibreType = measure.fibreType
                        new.strength = Int64(measure.strength)
                        new.dosageRate = measure.dosageRate
                        new.performance = measure.performance
                        new.unit = index == 0 ? "imperial" : "metric"
                    }
                }
                commit ? Database.save(context: privateMOC) : ()
            }
            completion?(true)
        }
        
        guard truncateExisting else {
            insert()
            return
        }
        truncate(from: privateMOC, commit: commit) { _ in insert() }
    }
}

extension CalculatorParams {
    static func insert(_ items: ([String: Any], [String: Any], [String: Any]),
                       truncateExisting: Bool = false,
                       commit: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        let privateMOC = Database.privateContext

        let insert = {
            let new = newRow(in: privateMOC)
            let bendingData =  try JSONSerialization.data(withJSONObject: items.0)
            let bendingString = String(data: bendingData, encoding: .utf8)
            
            let shrinkageData =  try JSONSerialization.data(withJSONObject: items.1)
            let shrinkageString = String(data: shrinkageData, encoding: .utf8)
            
            let flooringData =  try JSONSerialization.data(withJSONObject: items.2)
            let flooringString = String(data: flooringData, encoding: .utf8)
            
            new.bending = bendingString
            new.shrinkage = shrinkageString
            new.flooring = flooringString

            commit ? Database.save(context: privateMOC) : ()
            completion?(true)
        }
        
        guard truncateExisting else {
            try? insert()
            return
        }
        truncate(from: privateMOC, commit: commit) { _ in try? insert() }
    }
}

extension SubgradeConfig {
    static func insert(_ items: Lookup.Optimised,
                       truncateExisting: Bool = false,
                       commit: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        let privateMOC = Database.privateContext

        let insert = {
            items.subgrades.forEach { subgrade in
                let new = newRow(in: privateMOC)
                new.id = Int64(subgrade.id)
                new.fibreTypeID = Int64(subgrade.fibreTypeID)
                new.fibreType = subgrade.fibreType
                new.location = subgrade.location
                new.k = subgrade.k
                new.cbr = Int64(subgrade.cbr)
                new.ev2 = Int64(subgrade.ev2)
                
                var dosages: [SubgradeDosageConfig] = []
                items.subgradeDosage.filter { $0.subgradeID == subgrade.id }.forEach { subgradeDosage in
                    let newSubgradeDosage = SubgradeDosageConfig.newRow(in: privateMOC)
                    newSubgradeDosage.id = Int64(subgradeDosage.id)
                    newSubgradeDosage.subgradeID = Int64(subgradeDosage.subgradeID)
                    newSubgradeDosage.dosage = subgradeDosage.dosage
                    
                    var thicknesses: [SlabThicknessConfig] = []
                    
                    items.slabThickness.filter { $0.subgradeDosageID == subgradeDosage.id }.forEach { thickness in

                        let newSlabThickness = SlabThicknessConfig.newRow(in: privateMOC)
                        newSlabThickness.id = Int64(thickness.id)
                        newSlabThickness.subgradeDosageID = Int64(thickness.subgradeDosageID)
                        newSlabThickness.loadCombinationID = Int64(thickness.loadCombinationID)
                        newSlabThickness.thickness = Int64(thickness.thickness)
                        thicknesses.append(newSlabThickness)
                    }
                    
                    newSubgradeDosage.addToSlabThicknessConfig(NSSet(array: thicknesses))
                    dosages.append(newSubgradeDosage)
                }
                new.addToSubgradeDosageConfig(NSSet(array: dosages))
                commit ? Database.save(context: privateMOC) : ()
            }
            completion?(true)
        }
        
        guard truncateExisting else {
            insert()
            return
        }
        truncate(from: privateMOC, commit: commit) { _ in insert() }
    }
}

extension OfflineSync {
    static func insert(_ items: [Int: Data],
                       truncateExisting: Bool = false,
                       commit: Bool = true,
                       completion: ((Bool) -> Void)? = nil) {
        let privateMOC = Database.privateContext

        let insert = {
            items.forEach {
                let new = newRow(in: privateMOC)
                new.id = Int64($0.key)
                new.calculationData = $0.value
                commit ? Database.save(context: privateMOC) : ()
            }
            completion?(true)
        }
        guard truncateExisting else {
            insert()
            return
        }
        truncate(from: privateMOC, commit: commit) { _ in insert() }
    }
}




//let predicate1 = \Person.name == "John" && \Person.age >= 18


//let predicateX = \PerformanceConfig.unit == "imperial" &&
//    \PerformanceConfig.fiberTypeId == 1 &&
//    \PerformanceConfig.strength == 3500 &&
//    \PerformanceConfig.calculatorTypeId == 2

//CalculatorTypeConfig.fetch(matching: \CalculatorTypeConfig.id == 1) { (fetchdData) in
//
//}
