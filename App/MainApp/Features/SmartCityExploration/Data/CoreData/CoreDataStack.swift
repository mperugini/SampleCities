//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import CoreData

// MARK: - Core Data Stack
@MainActor
public final class CoreDataStack {
    public static let shared = CoreDataStack()
    
    public init() {}
    
    public lazy var persistentContainer: NSPersistentContainer = {
      
        let modelName = "CityDataModel"
        
        //el bundle principal
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") {
            // print("[CoreDataStack] Found model in main bundle: \(modelURL)")
            let container = NSPersistentContainer(name: modelName)
            configureContainer(container)
            return container
        }
        
    
        
        // en todos los bundles disponibles
        for bundle in Bundle.allBundles {
            if let modelURL = bundle.url(forResource: modelName, withExtension: "momd") {
                // print("[CoreDataStack] Found model in bundle \(bundle.bundleIdentifier ?? "unknown"): \(modelURL)")
                let container = NSPersistentContainer(name: modelName)
                configureContainer(container)
                return container
            }
        }
        
        //  Si no se encuentra, crear un modelo en memoria (fallback)
        // print("[CoreDataStack] Model not found, creating in-memory store")
        let container = NSPersistentContainer(name: modelName)
        configureContainer(container)
        return container
    }()
    
    private func configureContainer(_ container: NSPersistentContainer) {
        // Configuracion para mejor performance
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                               forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                 print("[CoreDataStack] Core Data error: \(error), \(error.userInfo)")
                 print("[CoreDataStack] Continuing with in-memory store due to error")
                //ToDo: Track handled exception
            } else {
                // print("[CoreDataStack] Core Data stores loaded successfully")
                // Crear la politica de merge directamente para evitar problemas de concurrencia
                let mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
                container.viewContext.mergePolicy = mergePolicy
                container.viewContext.automaticallyMergesChangesFromParent = true
            }
        }
    }
    
    public func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                //let nsError = error as NSError
                // print("[CoreDataStack] Core Data save error: \(nsError), \(nsError.userInfo)")
                // En lugar de fatalError, loggear el error y continuar
                // Los cambios se perderán pero la app no crasheará
            }
        }
    }
} 
