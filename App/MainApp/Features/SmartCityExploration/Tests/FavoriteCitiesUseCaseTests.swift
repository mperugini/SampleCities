import XCTest
@testable import SmartCityExploration

final class FavoriteCitiesUseCaseTests: XCTestCase {
    
    var useCase: FavoriteCitiesUseCaseImpl!
    var mockRepository: MockCityRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockCityRepository()
        useCase = FavoriteCitiesUseCaseImpl(repository: mockRepository)
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - getFavorites Tests
    
    func testGetFavoritesSuccess() async throws {
        // Given
        let expectedCities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1278, lat: 51.5074))
        ]
        mockRepository.favoriteCities = expectedCities
        
        // When
        let result = await useCase.getFavorites()
        
        // Then
        switch result {
        case .success(let cities):
            XCTAssertEqual(cities.count, 2)
            XCTAssertEqual(cities[0].id, 1)
            XCTAssertEqual(cities[0].name, "New York")
            XCTAssertEqual(cities[1].id, 2)
            XCTAssertEqual(cities[1].name, "London")
        case .failure(let error):
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testGetFavoritesFailure() async throws {
        // Given
        mockRepository.shouldFail = true
        mockRepository.error = DataError.dataNotFound
        
        // When
        let result = await useCase.getFavorites()
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error as? DataError, DataError.dataNotFound)
        }
    }
    
    // MARK: - toggleFavorite Tests
    
    func testToggleFavoriteSuccess() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        mockRepository.shouldFail = false
        
        // When
        await useCase.toggleFavorite(city)
        
        // Then
        XCTAssertEqual(mockRepository.toggleFavoriteCallCount, 1)
        XCTAssertEqual(mockRepository.lastToggledCity?.id, 1)
        XCTAssertEqual(mockRepository.lastToggledCity?.name, "New York")
    }
    
    func testToggleFavoriteFailure() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        mockRepository.shouldFail = true
        mockRepository.error = DataError.storageFailed(underlying: NSError(domain: "Test", code: 1)))
        
        // When
        await useCase.toggleFavorite(city)
        
        // Then
        XCTAssertEqual(mockRepository.toggleFavoriteCallCount, 1)
        // Should not throw error to avoid breaking UI
    }
    
    // MARK: - isFavorite Tests
    
    func testIsFavoriteTrue() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        let favoriteCities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1278, lat: 51.5074))
        ]
        mockRepository.favoriteCities = favoriteCities
        
        // When
        let isFavorite = await useCase.isFavorite(city)
        
        // Then
        XCTAssertTrue(isFavorite)
        XCTAssertEqual(mockRepository.getFavoriteCitiesCallCount, 1)
    }
    
    func testIsFavoriteFalse() async throws {
        // Given
        let city = City(id: 3, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566))
        let favoriteCities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1278, lat: 51.5074))
        ]
        mockRepository.favoriteCities = favoriteCities
        
        // When
        let isFavorite = await useCase.isFavorite(city)
        
        // Then
        XCTAssertFalse(isFavorite)
        XCTAssertEqual(mockRepository.getFavoriteCitiesCallCount, 1)
    }
    
    func testIsFavoriteWithEmptyFavorites() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        mockRepository.favoriteCities = []
        
        // When
        let isFavorite = await useCase.isFavorite(city)
        
        // Then
        XCTAssertFalse(isFavorite)
    }
    
    func testIsFavoriteFailure() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        mockRepository.shouldFail = true
        mockRepository.error = DataError.dataNotFound
        
        // When
        let isFavorite = await useCase.isFavorite(city)
        
        // Then
        XCTAssertFalse(isFavorite) // Should return false on error
    }
    
    // MARK: - Integration Tests
    
    func testToggleFavoriteThenCheckIsFavorite() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        mockRepository.favoriteCities = []
        
        // When - Initially not favorite
        let initiallyFavorite = await useCase.isFavorite(city)
        
        // Then
        XCTAssertFalse(initiallyFavorite)
        
        // When - Toggle to favorite
        await useCase.toggleFavorite(city)
        
        // Simulate repository state change
        mockRepository.favoriteCities = [city]
        
        // Then - Should be favorite
        let afterToggle = await useCase.isFavorite(city)
        XCTAssertTrue(afterToggle)
    }
    
    func testMultipleToggleFavoriteCalls() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        
        // When - Multiple toggle calls
        await useCase.toggleFavorite(city)
        await useCase.toggleFavorite(city)
        await useCase.toggleFavorite(city)
        
        // Then
        XCTAssertEqual(mockRepository.toggleFavoriteCallCount, 3)
        XCTAssertEqual(mockRepository.lastToggledCity?.id, 1)
    }
    
    func testConcurrentToggleFavoriteCalls() async throws {
        // Given
        let city = City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        
        // When - Concurrent toggle calls
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    await self.useCase.toggleFavorite(city)
                }
            }
        }
        
        // Then
        XCTAssertEqual(mockRepository.toggleFavoriteCallCount, 10)
    }
}

// MARK: - Mock Implementation

private class MockCityRepository: CityRepository {
    var favoriteCities: [City] = []
    var shouldFail = false
    var error: Error = DataError.dataNotFound
    var toggleFavoriteCallCount = 0
    var getFavoriteCitiesCallCount = 0
    var lastToggledCity: City?
    
    func loadCities() async -> Result<[City], Error> {
        if shouldFail {
            return .failure(error)
        }
        return .success([])
    }
    
    func getFavoriteCities() async -> Result<[City], Error> {
        getFavoriteCitiesCallCount += 1
        if shouldFail {
            return .failure(error)
        }
        return .success(favoriteCities)
    }
    
    func toggleFavorite(_ city: City) async -> Result<Void, Error> {
        toggleFavoriteCallCount += 1
        lastToggledCity = city
        
        if shouldFail {
            return .failure(error)
        }
        
        // Simulate toggling in the mock
        if let index = favoriteCities.firstIndex(where: { $0.id == city.id }) {
            favoriteCities.remove(at: index)
        } else {
            favoriteCities.append(city)
        }
        
        return .success(())
    }
    
    func refreshCities() async -> Result<Void, Error> {
        if shouldFail {
            return .failure(error)
        }
        return .success(())
    }
} 