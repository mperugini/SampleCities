//
//  CityDataManager.swift
//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import CoreData

// MARK: - Cache Configuration
public struct CacheConfiguration: Sendable {
    let maxEntries: Int
    let maxMemoryMB: Int
    let evictionPolicy: CacheEvictionPolicy
    let enableMetrics: Bool
    
    public static let `default` = CacheConfiguration(
        maxEntries: 200,
        maxMemoryMB: 100,
        evictionPolicy: .lru,
        enableMetrics: true
    )
    
    public static let aggressive = CacheConfiguration(
        maxEntries: 50,
        maxMemoryMB: 25,
        evictionPolicy: .lru,
        enableMetrics: true
    )
    
    public static let generous = CacheConfiguration(
        maxEntries: 500,
        maxMemoryMB: 200,
        evictionPolicy: .lru,
        enableMetrics: true
    )
}

public enum CacheEvictionPolicy: Sendable {
    case lru      // least recently used
    case lfu      // least frequently used
    case fifo     // first in first Out
}

// MARK: - Cache Entry
private struct CacheEntry: Sendable {
    let data: [City]
    let timestamp: Date
    var accessCount: Int
    let size: Int
    
    init(data: [City], size: Int) {
        self.data = data
        self.timestamp = Date()
        self.accessCount = 1
        self.size = size
    }
}

// MARK: - Cache Metrics
public struct CacheMetrics: Sendable {
    var hits: Int
    var misses: Int
    var evictions: Int
    var currentSize: Int
    var maxSize: Int
    var hitRate: Double
    
    var hitRatePercentage: Double {
        return hitRate * 100
    }
}

// MARK: - Protocolo para testeo y abstraccion
public protocol CityDataManagerProtocol: Sendable {
    func loadAllCities() async -> [City]
    func loadCitiesWithDownload() async -> [City]
    func searchCitiesByName(prefix: String, limit: Int) async -> [City]
    func getFavoriteCities() async -> [City]
    func toggleFavorite(for cityId: Int) async -> Bool
    func getStats() async -> DataManagerStats
    func getCacheMetrics() async -> CacheMetrics
    func getCacheConfiguration() async -> CacheConfiguration
    func refreshCities() async -> Bool
}

// MARK: -  City Data Manager
public actor CityDataManager: CityDataManagerProtocol, Sendable {
    private let container: NSPersistentContainer
    private let cacheManager: CacheManager
    private let networkService: NetworkService?
    
    // Actor para manejar el cache de manera segura con l1mites de memoria
    actor CacheManager {
        private var cache: [String: CacheEntry] = [:]
        private let configuration: CacheConfiguration
        private var metrics = CacheMetrics(hits: 0, misses: 0, evictions: 0, currentSize: 0, maxSize: 0, hitRate: 0.0)
        
        init(configuration: CacheConfiguration = .default) {
            self.configuration = configuration
            self.metrics.maxSize = configuration.maxMemoryMB * 1024 * 1024
            // print("[CacheManager] Initialized with \(configuration.maxEntries) max entries, \(configuration.maxMemoryMB)MB max memory")
        }
        
        func setObject(_ object: [City], forKey key: String) {
            let size = estimateSize(for: object)
            
            // Check if we need to evict entries before adding
            if shouldEvict(for: size) {
                evictEntries(for: size)
            }
            
            let entry = CacheEntry(data: object, size: size)
            cache[key] = entry
            metrics.currentSize += size
            
            if configuration.enableMetrics {
                // print("[CacheManager] Added entry '\(key)' (size: \(size) bytes, total: \(metrics.currentSize) bytes)")
            }
        }
        
        func object(forKey key: String) -> [City]? {
            guard let entry = cache[key] else {
                metrics.misses += 1
                updateHitRate()
                return nil
            }
            
            // Update access metrics
            var updatedEntry = entry
            updatedEntry.accessCount += 1
            cache[key] = updatedEntry
            
            metrics.hits += 1
            updateHitRate()
            
            if configuration.enableMetrics {
                // print("[CacheManager] Cache hit for '\(key)' (access count: \(updatedEntry.accessCount))")
            }
            
            return entry.data
        }
        
        func removeObject(forKey key: String) {
            if let entry = cache.removeValue(forKey: key) {
                metrics.currentSize -= entry.size
                if configuration.enableMetrics {
                    // print("[CacheManager] Removed entry '\(key)' (freed: \(entry.size) bytes)")
                }
            }
        }
        
        func removeAllObjects() {
           // let freedSize = metrics.currentSize
            cache.removeAll()
            metrics.currentSize = 0
            if configuration.enableMetrics {
                // print("[CacheManager] Cleared all cache (freed: \(freedSize) bytes)")
            }
        }
        
        func getMetrics() -> CacheMetrics {
            return metrics
        }
        
        func getConfiguration() -> CacheConfiguration {
            return configuration
        }
        
        // MARK: - Private Methods
        
        private func estimateSize(for cities: [City]) -> Int {
            // Estimacion aproximada: 200 bytes por ciudad
            return cities.count * 200
        }
        
        private func shouldEvict(for newSize: Int) -> Bool {
            return cache.count >= configuration.maxEntries || 
                   (metrics.currentSize + newSize) > metrics.maxSize
        }
        
        private func evictEntries(for requiredSize: Int) {
            let entriesToEvict = selectEntriesToEvict(for: requiredSize)
            
            for key in entriesToEvict {
                if let entry = cache.removeValue(forKey: key) {
                    metrics.currentSize -= entry.size
                    metrics.evictions += 1
                    
                    if configuration.enableMetrics {
                        // print("[CacheManager] Evicted '\(key)' (size: \(entry.size) bytes, reason: \(configuration.evictionPolicy))")
                    }
                }
            }
        }
        
        private func selectEntriesToEvict(for requiredSize: Int) -> [String] {
            switch configuration.evictionPolicy {
            case .lru:
                return selectLRUEntries(for: requiredSize)
            case .lfu:
                return selectLFUEntries(for: requiredSize)
            case .fifo:
                return selectFIFOEntries(for: requiredSize)
            }
        }
        
        private func selectLRUEntries(for requiredSize: Int) -> [String] {
            let sortedEntries = cache.sorted { $0.value.timestamp < $1.value.timestamp }
            return selectEntriesFromSorted(sortedEntries, for: requiredSize)
        }
        
        private func selectLFUEntries(for requiredSize: Int) -> [String] {
            let sortedEntries = cache.sorted { $0.value.accessCount < $1.value.accessCount }
            return selectEntriesFromSorted(sortedEntries, for: requiredSize)
        }
        
        private func selectFIFOEntries(for requiredSize: Int) -> [String] {
            let sortedEntries = cache.sorted { $0.value.timestamp < $1.value.timestamp }
            return selectEntriesFromSorted(sortedEntries, for: requiredSize)
        }
        
        private func selectEntriesFromSorted(_ sortedEntries: [(key: String, value: CacheEntry)], for requiredSize: Int) -> [String] {
            var selectedKeys: [String] = []
            var freedSize = 0
            
            for (key, entry) in sortedEntries {
                selectedKeys.append(key)
                freedSize += entry.size
                
                if freedSize >= requiredSize {
                    break
                }
            }
            
            return selectedKeys
        }
        
        private func updateHitRate() {
            let total = metrics.hits + metrics.misses
            metrics.hitRate = total > 0 ? Double(metrics.hits) / Double(total) : 0.0
        }
    }
    
    public init(container: NSPersistentContainer, networkService: NetworkService? = nil, cacheConfiguration: CacheConfiguration = .default) {
        self.container = container
        self.networkService = networkService
        self.cacheManager = CacheManager(configuration: cacheConfiguration)
        // print("[CityDataManager] Initialized as actor with cache configuration: \(cacheConfiguration.maxEntries) entries, \(cacheConfiguration.maxMemoryMB)MB")
    }
    
    // MARK: - Public Interface
    
    public func loadAllCities() async -> [City] {
        return _loadAllCities()
    }
    
    public func loadCitiesWithDownload() async -> [City] {
        // First try to load from Core Data
        let cities = await loadAllCities()
        
        if !cities.isEmpty {
            // print("[CityDataManager] Found \(cities.count) cities in Core Data")
            return cities
        }
        
        // If no cities in Core Data, try to download
        if let networkService = networkService {
            // print("[CityDataManager] No cities in Core Data, attempting download...")
            return await downloadAndSaveCities(networkService: networkService)
        }
        
        // print("[CityDataManager] No cities found and no network service available")
        return []
    }
    
    public func searchCitiesByName(prefix: String, limit: Int = 50) async -> [City] {
        return await _searchCitiesByName(prefix: prefix, limit: limit)
    }
    
    public func getFavoriteCities() async -> [City] {
        return _getFavoriteCities()
    }
    
    public func toggleFavorite(for cityId: Int) async -> Bool {
        return _toggleFavorite(for: cityId)
    }
    
    public func getStats() async -> DataManagerStats {
        let cacheStats = await cacheManager.getMetrics()
        return _getStats(cacheStats: cacheStats)
    }
    
    public func getCacheMetrics() async -> CacheMetrics {
        return await cacheManager.getMetrics()
    }
    
    public func getCacheConfiguration() async -> CacheConfiguration {
        return await cacheManager.getConfiguration()
    }
    
    public func refreshCities() async -> Bool {
        guard let networkService = networkService else {
            // print("[CityDataManager] No network service available for refresh")
            return false
        }
        
        // print("[CityDataManager] Starting refresh from network...")
        let cities = await downloadAndSaveCities(networkService: networkService)
        return !cities.isEmpty
    }
    
    // MARK: - Private Implementation
    
    private func downloadAndSaveCities(networkService: NetworkService) async -> [City] {
        do {
            // print("[CityDataManager] Downloading cities from network...")
            
            let cityResponses = try await networkService.downloadCities()
            // print("[CityDataManager] Downloaded \(cityResponses.count) cities from network")
            
            // Convert CityResponse to City
            let cities = cityResponses.map { response in
                let city = City(
                    id: response.id,
                    name: response.name,
                    country: response.country,
                    coord: City.Coordinate(lon: response.coord.lon, lat: response.coord.lat),
                    isFavorite: false
                )
                return city
            }
            
            // print("[CityDataManager] Converted \(cities.count) cities to domain model")
            
            // Save to Core Data
            await saveCitiesToCoreData(cities)
            
            // Clear cache
            await cacheManager.removeAllObjects()
            
            return cities
            
        } catch {
            // print("[CityDataManager] Network download failed: \(error)")
            return []
        }
    }
    
    private func saveCitiesToCoreData(_ cities: [City]) async {
        let context = container.newBackgroundContext()
        
        context.performAndWait {
            do {
                // Clear existing cities
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deleteRequest)
                // print("[CityDataManager] Cleared all existing cities from Core Data")
                
                // Save new cities
                for city in cities {
                    let entity = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "CityEntity", in: context)!, insertInto: context)
                    entity.setValue(Int32(city.id), forKey: "id")
                    entity.setValue(city.name, forKey: "name")
                    entity.setValue(city.country, forKey: "country")
                    entity.setValue(city.coord.lat, forKey: "latitude")
                    entity.setValue(city.coord.lon, forKey: "longitude")
                    entity.setValue(city.isFavorite, forKey: "isFavorite")
                    entity.setValue(Date(), forKey: "createdAt")
                }
                
                try context.save()
                // print("[CityDataManager] Successfully saved \(cities.count) cities to Core Data")
                
            } catch {
                // print("[CityDataManager] Error saving cities to Core Data: \(error)")
            }
        }
    }
    
    private func _loadAllCities() -> [City] {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
        
        do {
            let entities = try context.fetch(request)
            let cities = entities.map { City(from: $0) }
            return cities
        } catch {
            // print("[CityDataManager] Error loading cities: \(error)")
            return []
        }
    }
    
    private func _searchCitiesByName(prefix: String, limit: Int) async -> [City] {
        let cacheKey = "name_\(prefix)_\(limit)"
        
        if let cached = await cacheManager.object(forKey: cacheKey) {
            // print("[CityDataManager] Cache hit for prefix '\(prefix)'")
            return cached
        }
        
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
        
        request.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", prefix)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                                   NSSortDescriptor(key: "country", ascending: true)]
        
        request.fetchLimit = limit
        
        do {
            let entities = try context.fetch(request)
            let cities = entities.map { City(from: $0) }
            await cacheManager.setObject(cities, forKey: cacheKey)
            
            // print("[CityDataManager] Found \(cities.count) cities for prefix '\(prefix)'")
            return cities
        } catch {
            // print("[CityDataManager] Error searching cities: \(error)")
            return []
        }
    }
    
    private func _getFavoriteCities() -> [City] {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
        
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            let cities = entities.map { City(from: $0) }
            // print("[CityDataManager] Found \(cities.count) favorite cities")
            return cities
        } catch {
            // print("[CityDataManager] Error loading favorites: \(error)")
            return []
        }
    }
    
    private func _toggleFavorite(for cityId: Int) -> Bool {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
        request.predicate = NSPredicate(format: "id == %d", cityId)
        request.fetchLimit = 1
        
        do {
            let entities = try context.fetch(request)
            guard let entity = entities.first else { return false }
            
            let currentFavorite = entity.value(forKey: "isFavorite") as? Bool ?? false
            entity.setValue(!currentFavorite, forKey: "isFavorite")
            
            try context.save()
            // Note: cache clearing will be handled by the caller
            
            // print("[CityDataManager] Toggled favorite for city \(cityId): \(!currentFavorite)")
            return true
        } catch {
            // print("[CityDataManager] Error toggling favorite: \(error)")
            return false
        }
    }
    
    private func _getStats(cacheStats: CacheMetrics) -> DataManagerStats {
        let context = container.viewContext
        
        // Get total cities
        let totalRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
        let totalCities = (try? context.count(for: totalRequest)) ?? 0
        
        // Get favorite cities
        let favoriteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
        favoriteRequest.predicate = NSPredicate(format: "isFavorite == YES")
        let favoriteCities = (try? context.count(for: favoriteRequest)) ?? 0
        
        return DataManagerStats(
            totalCities: totalCities,
            favoriteCities: favoriteCities,
            cacheSize: cacheStats.currentSize,
            cacheEntries: cacheStats.hits + cacheStats.misses
        )
    }
}

// MARK: - Data Manager Statistics
public struct DataManagerStats: Sendable {
    public let totalCities: Int
    public let favoriteCities: Int
    public let cacheSize: Int
    public let cacheEntries: Int
    
    public var cacheSizeMB: Double {
        Double(cacheSize) / 1024 / 1024
    }
} 
