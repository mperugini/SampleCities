//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import CoreData

public final class LocalDataSourceImpl: LocalDataSource {
    private let coreDataStack: CoreDataStack
    
    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    public func saveCities(_ cities: [City]) async throws {
        // print("[LocalDataSource] Saving \(cities.count) cities to Core Data...")
        
        let context = await coreDataStack.persistentContainer.newBackgroundContext()
        
        return try await context.perform {
            // Clear existing cities
            try self.clearAllCities(in: context)
            
            // Save new cities
            for city in cities {
                let entity = CityEntity(context: context)
                entity.id = Int32(city.id)
                entity.name = city.name
                entity.country = city.country
                entity.latitude = NSNumber(value: city.coord.lat)
                entity.longitude = NSNumber(value: city.coord.lon)
                entity.isFavorite = city.isFavorite
                entity.createdAt = Date()
            }
            
            try context.save()
            // print("[LocalDataSource] Successfully saved \(cities.count) cities to Core Data")
        }
    }
    
    public func getAllCities() async -> Result<[City], Error> {
        let context = await coreDataStack.persistentContainer.viewContext
        
        return await context.perform {
            do {
                let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                
                let entities = try context.fetch(request)
                // print("[LocalDataSource] Found \(entities.count) cities in Core Data")
                
                let cities = entities.map { entity in
                    City(
                        id: Int(entity.id),
                        name: entity.name ?? "Unknown",
                        country: entity.country ?? "Unknown",
                        coord: City.Coordinate(lon: entity.longitude?.doubleValue ?? 0.0, lat: entity.latitude?.doubleValue ?? 0.0),
                        isFavorite: entity.isFavorite
                    )
                }
                
                return Swift.Result.success(cities)
            } catch {
                // print("[LocalDataSource] Error getting all cities: \(error)")
                return Swift.Result.failure(error)
            }
        }
    }
    
    public func getFavoriteCities() async -> Result<[City], Error> {
        let context = await coreDataStack.persistentContainer.viewContext
        
        return await context.perform {
            do {
                let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                request.predicate = NSPredicate(format: "isFavorite == TRUE")
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                
                let entities = try context.fetch(request)
                // print("[LocalDataSource] Found \(entities.count) favorite cities in Core Data")
                
                let cities = entities.map { entity in
                    City(
                        id: Int(entity.id),
                        name: entity.name ?? "Unknown",
                        country: entity.country ?? "Unknown",
                        coord: City.Coordinate(lon: entity.longitude?.doubleValue ?? 0.0, lat: entity.latitude?.doubleValue ?? 0.0),
                        isFavorite: entity.isFavorite
                    )
                }
                
                return Swift.Result.success(cities)
            } catch {
                // print("[LocalDataSource] Error getting favorite cities: \(error)")
                return Swift.Result.failure(error)
            }
        }
    }
    
    public func toggleFavorite(_ city: City) async throws {
        let context = await coreDataStack.persistentContainer.viewContext
        
        try await context.perform {
            let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", Int32(city.id))
            request.fetchLimit = 1
            
            let entities = try context.fetch(request)
            guard let entity = entities.first else {
                throw DataError.entityNotFound(entityName: "CityEntity with id \(city.id)")
            }
            
            entity.isFavorite.toggle()
            try context.save()
            
            // print("[LocalDataSource] Toggled favorite for city \(entity.name ?? "Unknown") (ID: \(city.id))")
        }
    }
    
    // MARK: - Private Methods
    
    private func clearAllCities(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<NSFetchRequestResult> = CityEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        // print("[LocalDataSource] Cleared all existing cities from Core Data")
    }
} 
