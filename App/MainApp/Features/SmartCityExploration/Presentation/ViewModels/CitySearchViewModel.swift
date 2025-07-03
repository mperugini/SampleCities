//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import Combine

@MainActor
@Observable
final class CitySearchViewModel: Sendable {
    // MARK: - Constants
    private let maxSearchResults = 20
    
    // MARK: - Published Properties
    var searchText = "" {
        didSet { scheduleSearch() }
    }
    var searchResults: [City] = []
    var isLoading = false
    var favorites: Set<Int> = []
    
    var onCitySelected: ((City) -> Void)?
    var onClose: (() -> Void)?
    
    // MARK: - Dependencies
    private let navigationService: any NavigationService
    
    private let searchUseCase: SearchCityUseCase
    private let favoritesUseCase: FavoriteCitiesUseCase
    private let analyticsService: AnalyticsService
    private let performanceMonitor: SearchPerformanceMonitor
    private let searchIndex: CitySearchIndex
    private var searchTask: Task<Void, Never>?
    
    init(
        searchUseCase: SearchCityUseCase,
        favoritesUseCase: FavoriteCitiesUseCase,
        analyticsService: AnalyticsService,
        performanceMonitor: SearchPerformanceMonitor,
        navigationService: any NavigationService,
        searchIndex: CitySearchIndex
    ) {
        self.searchUseCase = searchUseCase
        self.favoritesUseCase = favoritesUseCase
        self.analyticsService = analyticsService
        self.performanceMonitor = performanceMonitor
        self.navigationService = navigationService
        self.searchIndex = searchIndex
    }
    
    func loadInitialData() async {
        // print("[CitySearchViewModel] Starting to load initial data...")
        isLoading = true
        defer { isLoading = false }
        
        // Load favorites
        let favoritesResult = await favoritesUseCase.getFavorites()
        
        switch favoritesResult {
        case .success(let favorites):
            self.favorites = Set(favorites.map { $0.id })
        case .failure(_):
            self.favorites = []
        }
        
        // Build search index using AppContainer
        // print("[CitySearchViewModel] Building search index...")
        await AppContainer.shared.buildSearchIndex()
        
        // print("[CitySearchViewModel] Initial data loading completed successfully!")
    }
    
    func refreshCities() async {
        // print("[CitySearchViewModel] Starting city refresh process...")
        isLoading = true
        
        // Refresh cities from remote
        // print("[CitySearchViewModel] Refreshing cities from remote server...")
        let refreshResult = await searchUseCase.refreshCities()
        
        switch refreshResult {
        case .success:
             print("[CitySearchViewModel] Remote refresh completed")
        case .failure(let error):
             print("[CitySearchViewModel] Error refreshing from remote: \(error)")
            //ToDo: track exception
        }
        
        // Rebuild search index
        await AppContainer.shared.buildSearchIndex()
        // Reload favorites
        let favoritesResult = await favoritesUseCase.getFavorites()
        
        switch favoritesResult {
        case .success(let favorites):
            self.favorites = Set(favorites.map { $0.id })
            // print("[CitySearchViewModel] Reloaded \(favorites.count) favorite cities")
        case .failure(let error):
             print("[CitySearchViewModel] Error reloading favorites: \(error)")
            //ToDo: track exception
        }
        
        // print("[CitySearchViewModel] City refresh completed!")
        isLoading = false
    }
    
    private func scheduleSearch() {
        // print("[CitySearchViewModel] Scheduling search for: '\(searchText)'")
        
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            do {
                // Debounce search with Swift 6 Duration API
                // print("[CitySearchViewModel] Debouncing search for 300ms...")
                try await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { 
                    // print("[CitySearchViewModel] Search cancelled during debounce")
                    return 
                }
                
                // print("[CitySearchViewModel] Executing search for: '\(searchText)'")
                
                // Start performance monitoring
                performanceMonitor.startSearch(query: searchText)
                
                let searchResult = await searchUseCase.search(prefix: searchText)
                
                switch searchResult {
                case .success(let results):
                    // End performance monitoring
                    performanceMonitor.endSearch(resultCount: results.count)
                    
                    guard !Task.isCancelled else { 
                        // print("[CitySearchViewModel] Search cancelled after execution")
                        return 
                    }
                    
                    // Limit results for better performance
                    let limitedResults = Array(results.prefix(maxSearchResults))
                    
                    // print("[CitySearchViewModel] Search completed successfully!")
                    // print("[CitySearchViewModel] Found \(results.count) total results, showing first \(limitedResults.count) for query: '\(searchText)'")
                    self.searchResults = limitedResults
                    
                    // Track analytics
                    analyticsService.track(
                        "search_performed",
                        parameters: [
                            "query": searchText,
                            "result_count": results.count,
                            "limited_count": limitedResults.count
                        ]
                    )
                    
                case .failure(let error):
                    // print("[CitySearchViewModel] Search failed: \(error)")
                    self.searchResults = []
                    
                    // Track error analytics
                    analyticsService.track(
                        "search_error",
                        parameters: [
                            "query": searchText,
                            "error": String(describing: error)
                        ]
                    )
                }
             
            } catch {
                // print("[CitySearchViewModel] Search error: \(error)")
                // Handle cancellation
            }
        }
    }
    
    func selectCity(_ city: City) {
        // Debug log to verify city coordinates
        // print("[CitySearchViewModel] Selecting city: \(city.name)")
        // print("[CitySearchViewModel] City coordinates: lat=\(city.coord.lat), lon=\(city.coord.lon)")
        
        onCitySelected?(city)
        
        analyticsService.track(
            "city_selected",
            parameters: [
                "city_id": city.id,
                "city_name": city.name,
                "country": city.country,
                "lat": city.coord.lat,
                "lon": city.coord.lon
            ]
        )
    }
    
    func isFavorite(_ city: City) -> Bool {
        favorites.contains(city.id)
    }
    
    func toggleFavorite(_ city: City) async {
        await favoritesUseCase.toggleFavorite(city)
        
        // Update local state
        if favorites.contains(city.id) {
            favorites.remove(city.id)
        } else {
            favorites.insert(city.id)
        }
        
        let isFavorite = favorites.contains(city.id)
        analyticsService.track(
            "favorite_toggled",
            parameters: [
                "city_id": city.id,
                "is_favorite": isFavorite
            ]
        )
    }
    
    func close() {
        // print("[CitySearchViewModel] Closing view...")
        navigationService.dismiss(animated: true)
        onClose?()
    }
}

// MARK: - Notification extensions
extension Notification.Name {
    static let searchTextChanged = Notification.Name("searchTextChanged")
}
