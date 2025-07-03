//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
@preconcurrency import CoreData

// MARK: - Core Data Service Protocol
protocol CoreDataServiceProtocol: Sendable {
    func saveCities(_ cities: [CityResponse]) async throws
    func loadCities() async throws -> [NSManagedObject]
    func getFavoriteCities() async throws -> [NSManagedObject]
    func toggleFavorite(_ cityId: Int32) async throws
    func deleteAllCities() async throws
    func getCitiesCount() async throws -> Int
}

// MARK: - Core Data Service Implementation
actor CoreDataService: CoreDataServiceProtocol {
    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func saveCities(_ cities: [CityResponse]) async throws {
        let context = persistentContainer.newBackgroundContext()
        
        try await context.perform {
            // print("[CoreDataService] Starting to save \(cities.count) cities to Core Data...")
            
            // Crear un batch para mejor performance
            let batchSize = 1000
            let totalBatches = (cities.count + batchSize - 1) / batchSize
            
            // print("[CoreDataService] Will process \(cities.count) cities in \(totalBatches) batches of \(batchSize)")
            
            for batchIndex in 0..<totalBatches {
                let startIndex = batchIndex * batchSize
                let endIndex = min(startIndex + batchSize, cities.count)
                let batch = Array(cities[startIndex..<endIndex])
                
                // print("[CoreDataService] Processing batch \(batchIndex + 1)/\(totalBatches) (\(batch.count) cities) - Progress: \(Int((Double(batchIndex + 1) / Double(totalBatches)) * 100))%")
                
                for cityResponse in batch {
                    let cityEntity = NSEntityDescription.insertNewObject(forEntityName: "CityEntity", into: context)
                    cityEntity.setValue(Int32(cityResponse.id), forKey: "id")
                    cityEntity.setValue(cityResponse.name, forKey: "name")
                    cityEntity.setValue(cityResponse.country, forKey: "country")
                    cityEntity.setValue(cityResponse.coord.lon, forKey: "longitude")
                    cityEntity.setValue(cityResponse.coord.lat, forKey: "latitude")
                    cityEntity.setValue(false, forKey: "isFavorite")
                    cityEntity.setValue(Date(), forKey: "createdAt")
                }
                
                // Guardar cada batch
                do {
                    try context.save()
                    // print("[CoreDataService] Batch \(batchIndex + 1) saved successfully (\(startIndex + batch.count)/\(cities.count) cities)")
                } catch {
                    // print("[CoreDataService] Error saving batch \(batchIndex + 1): \(error)")
                    context.rollback()
                    throw error
                }
                
                // Reset context para liberar memoria
                context.reset()
            }
        }
        
        // print("[CoreDataService] All \(cities.count) cities saved to Core Data successfully")
    }
    
    func loadCities() async throws -> [NSManagedObject] {
        let context = persistentContainer.viewContext
        
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            let cities = try context.fetch(request)
            // print("[CoreDataService] Loaded \(cities.count) cities from Core Data")
            return cities
        }
    }
    
    func getFavoriteCities() async throws -> [NSManagedObject] {
        let context = persistentContainer.viewContext
        
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            request.predicate = NSPredicate(format: "isFavorite == TRUE")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            let favoriteCities = try context.fetch(request)
            // print("[CoreDataService] Loaded \(favoriteCities.count) favorite cities")
            return favoriteCities
        }
    }
    
    func toggleFavorite(_ cityId: Int32) async throws {
        let context = persistentContainer.viewContext
        
        try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            request.predicate = NSPredicate(format: "id == %d", cityId)
            request.fetchLimit = 1
            
            guard let city = try context.fetch(request).first else {
                throw CoreDataError.cityNotFound
            }
            
            let currentFavorite = city.value(forKey: "isFavorite") as? Bool ?? false
            city.setValue(!currentFavorite, forKey: "isFavorite")
            
            do {
                try context.save()
                let cityName = city.value(forKey: "name") as? String ?? "Unknown"
                 print("[CoreDataService] Toggled favorite for city: \(cityName) -> \(!currentFavorite)")
            } catch {
                context.rollback()
                throw error
            }
        }
    }
    
    func deleteAllCities() async throws {
        let context = persistentContainer.newBackgroundContext()
        
        try await context.perform {
            // print("[CoreDataService] Deleting all cities...")
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                // print("[CoreDataService] All cities deleted successfully")
            } catch {
                // print("[CoreDataService] Error deleting cities: \(error)")
                throw error
            }
        }
    }
    
    func getCitiesCount() async throws -> Int {
        let context = persistentContainer.viewContext
        
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            let count = try context.count(for: request)
            // print("[CoreDataService] Cities count: \(count)")
            return count
        }
    }
}

// MARK: - Core Data Errors
enum CoreDataError: Error, LocalizedError {
    case cityNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "City not found in database"
        case .saveFailed:
            return "Failed to save to database"
        }
    }
} 
