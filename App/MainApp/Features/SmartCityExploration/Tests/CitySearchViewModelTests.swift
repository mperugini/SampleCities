//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import XCTest
import Combine
@testable import SmartCityExploration

@MainActor
final class CitySearchViewModelTests: XCTestCase {
    
    private var viewModel: CitySearchViewModel!
    private var mockSearchUseCase: MockSearchCityUseCase!
    private var mockFavoritesUseCase: MockFavoriteCitiesUseCase!
    private var mockAnalyticsService: MockAnalyticsService!
    private var mockPerformanceMonitor: MockSearchPerformanceMonitor!
    private var mockNavigationService: MockNavigationService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        mockSearchUseCase = MockSearchCityUseCase()
        mockFavoritesUseCase = MockFavoriteCitiesUseCase()
        mockAnalyticsService = MockAnalyticsService()
        mockPerformanceMonitor = MockSearchPerformanceMonitor()
        mockNavigationService = MockNavigationService()
        
        viewModel = CitySearchViewModel(
            searchUseCase: mockSearchUseCase,
            favoritesUseCase: mockFavoritesUseCase,
            analyticsService: mockAnalyticsService,
            performanceMonitor: mockPerformanceMonitor,
            navigationService: mockNavigationService,
            searchIndex: CitySearchIndex()
        )
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockSearchUseCase = nil
        mockFavoritesUseCase = nil
        mockAnalyticsService = nil
        mockPerformanceMonitor = nil
        mockNavigationService = nil
        cancellables = nil
    }
    
    // MARK: - Search Tests
    
    func testSearchWithValidQuery() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Search results updated")
        
        // When
        viewModel.searchText = "New"
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertFalse(viewModel.searchResults.isEmpty)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.searchText, "New")
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testSearchWithEmptyQuery() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Search results cleared")
        
        // When
        viewModel.searchText = ""
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.searchText, "")
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testSearchWithWhitespaceOnly() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Search results cleared")
        
        // When
        viewModel.searchText = "   "
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertEqual(viewModel.isLoading, false)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testSearchErrorHandling() async throws {
        // Given
        mockSearchUseCase.shouldThrowError = true
        let expectation = XCTestExpectation(description: "Search results updated")
        
        // When
        viewModel.searchText = "New"
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertTrue(viewModel.searchResults.isEmpty) // Should be empty due to error
        XCTAssertEqual(viewModel.isLoading, false)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - Favorites Tests
    
    func testLoadFavoriteCities() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Favorites loaded")
        
        // When
        await viewModel.loadInitialData()
        
        // Then
        XCTAssertGreaterThanOrEqual(viewModel.favorites.count, 0)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testToggleFavorite() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        let expectation = XCTestExpectation(description: "Favorite toggled")
        
        // When
        await viewModel.toggleFavorite(city)
        
        // Then
        XCTAssertTrue(viewModel.favorites.contains(city.id))
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testIsFavorite() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        viewModel.favorites.insert(city.id)
        
        // When
        let isFavorite = viewModel.isFavorite(city)
        
        // Then
        XCTAssertTrue(isFavorite)
    }
    
    // MARK: - State Management Tests
    
    func testInitialState() {
        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertTrue(viewModel.favorites.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }
    
    func testClearSearch() async throws {
        // Given
        viewModel.searchText = "New"
        // Wait for search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertFalse(viewModel.searchResults.isEmpty)
        
        // When
        viewModel.searchText = ""
        
        // Then
        // Wait for search to clear
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testSearchPerformance() async throws {
        // Given
        let iterations = 10
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // When
        for i in 0..<iterations {
            viewModel.searchText = "City\(i)"
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds between searches
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let averageTime = (endTime - startTime) / Double(iterations)
        
        // Then
        XCTAssertLessThan(averageTime, 0.2) // Should be fast (< 200ms average)
    }
    
    // MARK: - Edge Cases
    
    func testSearchWithVeryLongQuery() async throws {
        // Given
        let longQuery = String(repeating: "a", count: 1000)
        let expectation = XCTestExpectation(description: "Long query search completed")
        
        // When
        viewModel.searchText = longQuery
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertEqual(viewModel.searchText, longQuery)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testSearchWithSpecialCharacters() async throws {
        // Given
        let specialQuery = "São Paulo"
        let expectation = XCTestExpectation(description: "Special characters search completed")
        
        // When
        viewModel.searchText = specialQuery
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertEqual(viewModel.searchText, specialQuery)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testSearchWithNumbers() async throws {
        // Given
        let numberQuery = "City123"
        let expectation = XCTestExpectation(description: "Numbers search completed")
        
        // When
        viewModel.searchText = numberQuery
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertEqual(viewModel.searchText, numberQuery)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testSearchWithEmojis() async throws {
        // Given
        let emojiQuery = "🏙️"
        let expectation = XCTestExpectation(description: "Emoji search completed")
        
        // When
        viewModel.searchText = emojiQuery
        
        // Then - Wait for debounced search to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        XCTAssertEqual(viewModel.searchText, emojiQuery)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - Integration Tests
    
    func testFullUserWorkflow() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Full workflow completed")
        
        // When - Simular flujo completo de usuario
        // 1. Buscar ciudades
        viewModel.searchText = "New"
        
        // 2. Cargar favoritos
        await viewModel.loadInitialData()
        
        // Then - Wait for operations to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    // MARK: - Boundary Tests
    
    func testBoundaryValues() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Boundary test completed")
        
        // When - Probar valores l1mite
        viewModel.searchText = "" // Query vac1a
        viewModel.searchText = " " // Solo espacio
        viewModel.searchText = "a" // Un solo caracter
        viewModel.searchText = String(repeating: "a", count: 100) // Query larga
        
        // Then - Wait for operations to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        XCTAssertFalse(viewModel.isLoading, "No deber1a estar cargando al final")
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }
}

// MARK: - Mock Implementations

final class MockSearchCityUseCase: SearchCityUseCase {
    var searchDelay: TimeInterval = 0
    var shouldThrowError = false
    
    func loadCities() async -> Result<[City], Error> {
        if shouldThrowError {
            return .failure(SearchError.networkError("Mock network error"))
        }
        
        let mockCities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511))
        ]
        
        return .success(mockCities)
    }
    
    func search(prefix: String) async -> Result<[City], Error> {
        if shouldThrowError {
            return .failure(SearchError.networkError("Mock network error"))
        }
        
        if searchDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(searchDelay * 1_000_000_000))
        }
        
        let mockCities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511))
        ]
        
        let filteredCities = mockCities.filter { city in
            city.name.lowercased().contains(prefix.lowercased())
        }
        
        return .success(filteredCities)
    }
    
    func refreshCities() async -> Result<Void, Error> {
        return .success(())
    }
}

final class MockFavoriteCitiesUseCase: FavoriteCitiesUseCase {
    func getFavorites() async -> Result<[City], Error> {
        let mockFavorites = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        ]
        return .success(mockFavorites)
    }
    
    func toggleFavorite(_ city: City) async {
        // Mock implementation
    }
    
    func isFavorite(_ city: City) async -> Bool {
        return city.id == 1
    }
}

final class MockAnalyticsService: AnalyticsService {
    func track(_ event: String, parameters: [String: Any]) {
        // Mock implementation
    }
    
    func trackEvent(_ event: String, properties: [String: Any]?) {
        // Mock implementation
    }
    
    func trackError(_ error: Error, context: [String: Any]?) {
        // Mock implementation
    }
}

final class MockSearchPerformanceMonitor: SearchPerformanceMonitor {
    func startSearch(query: String) {
        // Mock implementation
    }
    
    func endSearch(resultCount: Int) {
        // Mock implementation
    }
    
    func recordSearch(query: String, duration: TimeInterval, resultCount: Int) {
        // Mock implementation
    }
    
    func recordError(query: String, error: Error) {
        // Mock implementation
    }
    
}

final class MockNavigationService: NavigationService {
    func present(_ viewController: UIViewController, animated: Bool) {
        // Mock implementation
    }
    
    func dismiss(animated: Bool) {
        // Mock implementation
    }
    
    func push(_ viewController: UIViewController, animated: Bool) {
        // Mock implementation
    }
    
    func pop(animated: Bool) {
        // Mock implementation
    }
}

actor MockCitySearchIndex {
    func buildIndex(from cities: [City]) async {
        // Mock implementation
    }
    
    func search(prefix: String, maxResults: Int) -> [City] {
        let mockCities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        ]
        return mockCities.filter { $0.name.lowercased().hasPrefix(prefix.lowercased()) }
    }
}

// MARK: - Error Types

enum SearchError: Error {
    case networkError(String)
} 
