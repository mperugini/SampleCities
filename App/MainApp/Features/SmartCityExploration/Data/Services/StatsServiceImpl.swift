//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import CoreData

public final class StatsServiceImpl: StatsService {
    private let coreDataStack: CoreDataStack
    
    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    public func getTotalCities() async -> Result<Int, Error> {
        let context = await coreDataStack.persistentContainer.viewContext
        
        return await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            do {
                let count = try context.count(for: request)
                // print("[StatsService] Total cities in Core Data: \(count)")
                return Swift.Result.success(count)
            } catch {
                // print("[StatsService] Error getting total cities: \(error)")
                return Swift.Result.failure(error)
            }
        }
    }
    
    public func getFavoriteCitiesCount() async -> Result<Int, Error> {
        let context = await coreDataStack.persistentContainer.viewContext
        
        return await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "CityEntity")
            request.predicate = NSPredicate(format: "isFavorite == TRUE")
            do {
                let count = try context.count(for: request)
                // print("[StatsService] Favorite cities in Core Data: \(count)")
                return Swift.Result.success(count)
            } catch {
                // print("[StatsService] Error getting favorite cities: \(error)")
                return Swift.Result.failure(error)
            }
        }
    }
    
    public func getSearchStats() async -> SearchStats {
        // TODO: Implement search statistics from performance monitor
        return SearchStats(
            totalSearches: 0,
            averageSearchTime: 0.0,
            mostSearchedTerms: [],
            cacheHitRate: 0.0
        )
    }
    
    public func getPerformanceMetrics() async -> PerformanceMetrics {
        let memoryUsage = getMemoryUsage()
        let diskUsage = await getDiskUsage()
        
        return PerformanceMetrics(
            appLaunchTime: 0.0, // TODO: Track app launch time
            memoryUsage: memoryUsage,
            diskUsage: diskUsage,
            searchEnginePerformance: SearchEnginePerformance(
                optimizedEngineEnabled: true,
                averageSearchTime: 0.0,
                cacheHitRate: 0.0,
                totalQueries: 0
            )
        )
    }
    
    // MARK: - Private Methods
    
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        } else {
            return 0
        }
    }
    
    private func getDiskUsage() async -> Int64 {
        // TODO: Implement disk usage calculation
        return 0
    }
} 
