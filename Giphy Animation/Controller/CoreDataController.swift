//
//  CoreDataController.swift
//  Giphy Animation
//
//  Created by Admin on 21/08/23.
//

import Foundation
import UIKit
import CoreData

class CoreDataController {
    
    static let shared = CoreDataController()
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "GIFLocalModel") // Use your data model name
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    /// To Save GIF in Core Data
    func saveGIFData(data: Data, url: String, completion: @escaping (()->())) {
        let context = persistentContainer.viewContext
        
        let gifEntity = NSEntityDescription.entity(forEntityName: "GIFLocalEntity", in: context)!
        let gifManagedObject = NSManagedObject(entity: gifEntity, insertInto: context)
        
        gifManagedObject.setValue(data, forKey: "gifData")
        gifManagedObject.setValue(url, forKey: "urlString")

        do {
            try context.save()
            print("GIF data saved successfully.")
            completion()
        } catch {
            print("Failed to save GIF data: \(error)")
        }
    }
    
    /// To Fetch all the saved GIF URLs
    func fetchAllGIFURLs() -> [String] {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<GIFLocalEntity> = GIFLocalEntity.fetchRequest()
        
        do {
            let gifEntities = try context.fetch(fetchRequest)
            let gifURLStringArray = gifEntities.compactMap { $0.urlString }
            return gifURLStringArray
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    /// To Fetch all the saved GIF Data
    func fetchAllGIFData() -> [Data] {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<GIFLocalEntity> = GIFLocalEntity.fetchRequest()
        
        do {
            let gifEntities = try context.fetch(fetchRequest)
            let gifDataArray = gifEntities.compactMap { $0.gifData }
            return gifDataArray
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    /// Remove a Gif from CoreData
    func removeGIF(withUrl url: String, completion: @escaping (()->())) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<GIFLocalEntity> = GIFLocalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "urlString == %@", url)
        
        do {
            let fetchedRecords = try context.fetch(fetchRequest)
            for record in fetchedRecords {
                context.delete(record)
                completion()
            }
            
            try context.save()
            print("GIF record removed successfully.")
        } catch {
            print("Failed to remove GIF record: \(error)")
        }
    }
}
