import XCTest
import SwiftUI
@testable import SmartCityExploration

final class SmartCitySearchViewTests: XCTestCase {
    
    var viewModel: MockCitySearchViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MockCitySearchViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testSmartCitySearchViewInitialization() {
        // Given
        let city = City(
            id: 1,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        
        // When
        let view = SmartCitySearchView(viewModel: viewModel)
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testCityMapViewInitialization() {
        // Given
        let city = City(
            id: 1,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        
        // When
        let mapView = CityMapView(city: city)
        
        // Then
        XCTAssertNotNil(mapView)
        XCTAssertEqual(mapView.city.name, "New York")
        XCTAssertEqual(mapView.city.country, "USA")
    }
    
    func testCityRowViewInitialization() {
        // Given
        let city = City(
            id: 1,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        
        var favoriteToggled = false
        
        // When
        let rowView = CityRowView(
            city: city,
            isFavorite: false,
            onToggleFavorite: {
                favoriteToggled = true
            }
        )
        
        // Then
        XCTAssertNotNil(rowView)
    }
    
    func testCityMapKitConformance() {
        // Given
        let city = City(
            id: 1,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        
        let annotation = CityAnnotation(city: city)
        
        // When & Then
        XCTAssertEqual(annotation.coordinate.latitude, 40.7128)
        XCTAssertEqual(annotation.coordinate.longitude, -74.0060)
        XCTAssertEqual(annotation.title, "New York")
        XCTAssertEqual(annotation.subtitle, "USA")
    }
    
    func testCityEquatable() {
        // Given
        let city1 = City(
            id: 1,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        
        let city2 = City(
            id: 1,
            name: "New York",
            country: "USA",
            coord: City.Coordinate(lon: -74.0060, lat: 40.7128)
        )
        
        let city3 = City(
            id: 2,
            name: "London",
            country: "UK",
            coord: City.Coordinate(lon: -0.1278, lat: 51.5074)
        )
        
        // When & Then
        XCTAssertEqual(city1, city2)
        XCTAssertNotEqual(city1, city3)
    }
    
    func testCityCoordinateInitialization() {
        // Given
        let coordinate = City.Coordinate(lon: -74.0060, lat: 40.7128)
        
        // When & Then
        XCTAssertEqual(coordinate.lon, -74.0060)
        XCTAssertEqual(coordinate.lat, 40.7128)
    }
    
    func testCityFromCoreDataEntity() {
        // Given
        let entity = MockNSManagedObject()
        entity.setValue(Int32(1), forKey: "id")
        entity.setValue("New York", forKey: "name")
        entity.setValue("USA", forKey: "country")
        entity.setValue(-74.0060, forKey: "longitude")
        entity.setValue(40.7128, forKey: "latitude")
        entity.setValue(false, forKey: "isFavorite")
        
        // When
        let city = City(from: entity)
        
        // Then
        XCTAssertEqual(city.id, 1)
        XCTAssertEqual(city.name, "New York")
        XCTAssertEqual(city.country, "USA")
        XCTAssertEqual(city.coord.lon, -74.0060)
        XCTAssertEqual(city.coord.lat, 40.7128)
        XCTAssertFalse(city.isFavorite)
    }
}

// MARK: - Mock Classes

private class MockCitySearchViewModel: CitySearchViewModel {
    override init(
        searchUseCase: SearchCityUseCase = MockSearchCityUseCase(),
        favoritesUseCase: FavoriteCitiesUseCase = MockFavoriteCitiesUseCase(),
        analyticsService: AnalyticsService = MockAnalyticsService(),
        performanceMonitor: SearchPerformanceMonitor = MockSearchPerformanceMonitor(),
        navigationService: any NavigationService = MockNavigationService(),
        searchIndex: CitySearchIndex = MockCitySearchIndex()
    ) {
        super.init(
            searchUseCase: searchUseCase,
            favoritesUseCase: favoritesUseCase,
            analyticsService: analyticsService,
            performanceMonitor: performanceMonitor,
            navigationService: navigationService,
            searchIndex: searchIndex
        )
    }
}

private class MockNSManagedObject: NSManagedObject {
    private var values: [String: Any] = [:]
    
    override func value(forKey key: String) -> Any? {
        return values[key]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        values[key] = value
    }
}

private class MockSearchCityUseCase: SearchCityUseCase {
    func search(prefix: String) async -> Result<[City], Error> {
        return .success([])
    }
    
    func refreshCities() async -> Result<Void, Error> {
        return .success(())
    }
}

private class MockFavoriteCitiesUseCase: FavoriteCitiesUseCase {
    func getFavorites() async -> Result<[City], Error> {
        return .success([])
    }
    
    func toggleFavorite(_ city: City) async {
        // Mock implementation
    }
    
    func isFavorite(_ city: City) async -> Bool {
        return false
    }
}

private class MockAnalyticsService: AnalyticsService {
    func track(_ event: String, parameters: [String : Any]?) {
        // Mock implementation
    }
}

private class MockSearchPerformanceMonitor: SearchPerformanceMonitor {
    func startSearch(query: String) {
        // Mock implementation
    }
    
    func endSearch(resultCount: Int) {
        // Mock implementation
    }
}

private class MockNavigationService: NavigationService {
    func dismiss(animated: Bool) {
        // Mock implementation
    }
}

private class MockCitySearchIndex: CitySearchIndex {
    func search(prefix: String, limit: Int) async -> [City] {
        return []
    }
    
    func buildIndex(from cities: [City]) async {
        // Mock implementation
    }
} 