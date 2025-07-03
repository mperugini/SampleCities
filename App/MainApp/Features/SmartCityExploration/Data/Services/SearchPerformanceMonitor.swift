//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

public protocol SearchPerformanceMonitor: Sendable {
    func startSearch(query: String)
    func endSearch(resultCount: Int)
}

// Simple implementation for now
public struct SimpleSearchPerformanceMonitor: SearchPerformanceMonitor {
    public init() {}
    
    public func startSearch(query: String) {
        // print("[PerformanceMonitor] Starting search for: '\(query)'")
    }
    
    public func endSearch(resultCount: Int) {
        // print("[PerformanceMonitor] Search completed with \(resultCount) results")
    }
} 
