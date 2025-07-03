//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

public protocol StatsService: Sendable {
    func getTotalCities() async -> Result<Int, Error>
    func getFavoriteCitiesCount() async -> Result<Int, Error>
    func getSearchStats() async -> SearchStats
    func getPerformanceMetrics() async -> PerformanceMetrics
}

public struct SearchStats: Sendable {
    public let totalSearches: Int
    public let averageSearchTime: TimeInterval
    public let mostSearchedTerms: [String]
    public let cacheHitRate: Double
    
    public init(
        totalSearches: Int,
        averageSearchTime: TimeInterval,
        mostSearchedTerms: [String],
        cacheHitRate: Double
    ) {
        self.totalSearches = totalSearches
        self.averageSearchTime = averageSearchTime
        self.mostSearchedTerms = mostSearchedTerms
        self.cacheHitRate = cacheHitRate
    }
}

public struct PerformanceMetrics: Sendable {
    public let appLaunchTime: TimeInterval
    public let memoryUsage: Int64
    public let diskUsage: Int64
    public let searchEnginePerformance: SearchEnginePerformance
    
    public init(
        appLaunchTime: TimeInterval,
        memoryUsage: Int64,
        diskUsage: Int64,
        searchEnginePerformance: SearchEnginePerformance
    ) {
        self.appLaunchTime = appLaunchTime
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
        self.searchEnginePerformance = searchEnginePerformance
    }
}

public struct SearchEnginePerformance: Sendable {
    public let optimizedEngineEnabled: Bool
    public let averageSearchTime: TimeInterval
    public let cacheHitRate: Double
    public let totalQueries: Int
    
    public init(
        optimizedEngineEnabled: Bool,
        averageSearchTime: TimeInterval,
        cacheHitRate: Double,
        totalQueries: Int
    ) {
        self.optimizedEngineEnabled = optimizedEngineEnabled
        self.averageSearchTime = averageSearchTime
        self.cacheHitRate = cacheHitRate
        self.totalQueries = totalQueries
    }
} 
