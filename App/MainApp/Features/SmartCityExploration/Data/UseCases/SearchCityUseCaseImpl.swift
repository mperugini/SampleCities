//
//  SearchCityUseCaseImpl.swift
//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation


public final class SearchCityUseCaseImpl: SearchCityUseCase {
    private let repository: CityRepository
    private let searchIndex: CitySearchIndex
    
    public init(repository: CityRepository, searchIndex: CitySearchIndex) {
        self.repository = repository
        self.searchIndex = searchIndex
    }
    
    public func search(prefix: String) async -> Result<[City], Error> {
        // print("[SearchCityUseCase] Starting search for prefix: '\(prefix)'")
        
        // Validar entrada
        guard !prefix.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // print("[SearchCityUseCase] Empty search query")
            return .failure(DomainError.invalidSearchParameters)
        }
        
        guard prefix.count >= 1 else {
            // print("[SearchCityUseCase] Search query too short: '\(prefix)' (min: 1)")
            return .failure(DomainError.searchQueryTooShort(minLength: 1))
        }
        
        guard prefix.count <= 50 else {
            // print("[SearchCityUseCase] Search query too long: '\(prefix)' (max: 50)")
            return .failure(DomainError.searchQueryTooLong(maxLength: 50))
        }
        
        // print("[SearchCityUseCase] Search query validated, using search index...")
        
        // Use the search index instead of simple filtering
        let results = await searchIndex.search(prefix: prefix.lowercased())
        // print("[SearchCityUseCase] Search index returned \(results.count) results for '\(prefix)'")
        
        if results.isEmpty {
            // print("[SearchCityUseCase] No results found for '\(prefix)'")
        } else {
            // print("[SearchCityUseCase] Found results: \(results.prefix(9).map { "\($0.name), \($0.country)" })")
        }
        
        return Swift.Result.success(results)
    }
    
    public func loadCities() async -> Result<[City], Error> {
        return await repository.loadCities()
    }
    
    public func refreshCities() async -> Result<Void, Error> {
        return await repository.refreshCities()
    }
}

// MARK: - Array extension for chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
} 
