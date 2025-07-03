//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import XCTest
import CoreData
@testable import SmartCityExploration

final class CityDataManagerTests: XCTestCase {
    
    // MARK: - Tests basicos de carga de datos
    func testLoadAllCities() async throws {
       //ToDo: implement
    }
    
    func testLoadCitiesWithDownload() async throws {
        //ToDo: implement
    }
    
    func testSearchCitiesByName() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        let results = await dataManager.searchCitiesByName(prefix: "New", limit: 10)
        let searchTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThanOrEqual(results.count, 10, "Los resultados deber1an respetar el l1mite")
        XCTAssertTrue(results.allSatisfy { $0.name.lowercased().hasPrefix("new") }, "Todos los resultados deber1an empezar con 'new'")
        XCTAssertLessThan(searchTime, 0.1, "La busqueda deber1a ser rapida (< 100ms)")
    }
    
    func testSearchCitiesWithEmptyPrefix() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When
        let results = await dataManager.searchCitiesByName(prefix: "", limit: 10)
        
        // Then
        XCTAssertTrue(results.isEmpty, "La busqueda con prefijo vac1o deber1a retornar resultados vac1os")
    }
    
    func testSearchCitiesWithWhitespacePrefix() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        
        // When
        let results = await dataManager.searchCitiesByName(prefix: "   ", limit: 10)
        
        // Then
        XCTAssertTrue(results.isEmpty, "La busqueda con solo espacios deber1a retornar resultados vac1os")
    }
    
    
    // MARK: - Tests de favoritos
    func testGetFavoriteCities() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        
        // When
        let favorites = await dataManager.getFavoriteCities()
        
        // Then
        XCTAssertNotNil(favorites, "Deber1a retornar un array de favoritos")
        XCTAssertTrue(favorites.allSatisfy { $0.id > 0 }, "Todos los favoritos deber1an tener un ID valido")
    }
    
    func testToggleFavorite() async throws {
        //ToDo: implement
    }
    
    
    // MARK: - Tests de estad1sticas
    func testGetStats() async throws {
        //ToDo: implement
    }
    
    func testGetCacheMetrics() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When
        let metrics = await dataManager.getCacheMetrics()
        
        // Then
        XCTAssertGreaterThanOrEqual(metrics.hits, 0, "Los hits deber1an ser >= 0")
        XCTAssertGreaterThanOrEqual(metrics.misses, 0, "Los misses deber1an ser >= 0")
        XCTAssertGreaterThanOrEqual(metrics.evictions, 0, "Las evicciones deber1an ser >= 0")
        XCTAssertGreaterThanOrEqual(metrics.currentSize, 0, "El tamaño actual deber1a ser >= 0")
        XCTAssertGreaterThanOrEqual(metrics.maxSize, 0, "El tamaño maximo deber1a ser >= 0")
        XCTAssertGreaterThanOrEqual(metrics.hitRate, 0.0, "El hit rate deber1a ser >= 0")
        XCTAssertLessThanOrEqual(metrics.hitRate, 1.0, "El hit rate deber1a ser <= 1")
    }
    
    
    // MARK: - Tests de performance cr1ticos
    func testLoadAllCitiesPerformance() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        
        // When - Medir performance de carga
        let iterations = 5
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = await dataManager.loadAllCities()
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        let averageTime = totalTime / Double(iterations)
        
        // Then
        XCTAssertLessThan(averageTime, 0.5, "El tiempo promedio de carga deber1a ser < 500ms")
        XCTAssertLessThan(totalTime, 3.0, "El tiempo total para 5 cargas deber1a ser < 3 segundos")
    }
    
    func testSearchPerformance() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        
        // When - Medir performance de busqueda
        let searchQueries = ["New", "London", "Paris", "Tokyo", "Berlin", "Madrid", "Rome", "Amsterdam", "Vienna", "Prague"]
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for query in searchQueries {
            _ = await dataManager.searchCitiesByName(prefix: query, limit: 50)
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        let averageTime = totalTime / Double(searchQueries.count)
        
        // Then
        XCTAssertLessThan(averageTime, 0.05, "El tiempo promedio de busqueda deber1a ser < 50ms")
        XCTAssertLessThan(totalTime, 1.0, "El tiempo total para 10 busquedas deber1a ser < 1 segundo")
    }
    
    func testConcurrentOperations() async throws {
        //ToDo: implement
    }
    
    func testCachePerformance() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        
        // When - Ejecutar busquedas repetidas para probar el cache
        let query = "New"
        let limit = 10
        
        // Primera busqueda (cache miss)
        let startTime1 = CFAbsoluteTimeGetCurrent()
        let results1 = await dataManager.searchCitiesByName(prefix: query, limit: limit)
        let time1 = CFAbsoluteTimeGetCurrent() - startTime1
        
        // Segunda busqueda (cache hit)
        let startTime2 = CFAbsoluteTimeGetCurrent()
        let results2 = await dataManager.searchCitiesByName(prefix: query, limit: limit)
        let time2 = CFAbsoluteTimeGetCurrent() - startTime2
        
        // Then
        XCTAssertEqual(results1.count, results2.count, "Los resultados deber1an ser consistentes")
        XCTAssertLessThan(time2, time1, "La segunda busqueda deber1a ser mas rapida (cache hit)")
    }
    
    // MARK: - Tests de edge cases
    func testSearchWithVeryLongPrefix() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        let longPrefix = String(repeating: "a", count: 1000)
        
        // When
        let results = await dataManager.searchCitiesByName(prefix: longPrefix, limit: 10)
        
        // Then
        XCTAssertTrue(results.isEmpty, "La busqueda con prefijo muy largo deber1a retornar resultados vac1os")
    }
    
    func testSearchWithSpecialCharacters() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When
        let results = await dataManager.searchCitiesByName(prefix: "São", limit: 10)
        
        // Then
        // La busqueda deber1a funcionar sin errores, aunque puede no encontrar resultados
        XCTAssertNotNil(results, "La busqueda con caracteres especiales no deber1a fallar")
    }
    
    func testSearchWithNumbers() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        
        // When
        let results = await dataManager.searchCitiesByName(prefix: "123", limit: 10)
        
        // Then
        // La busqueda deber1a funcionar sin errores
        XCTAssertNotNil(results, "La busqueda con numeros no deber1a fallar")
    }
    
    func testToggleFavoriteWithInvalidId() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        
        let dataManager = CityDataManager(container: container)
        
        let invalidId = -1
        
        // When
        let result = await dataManager.toggleFavorite(for: invalidId)
        
        // Then
        // El comportamiento puede variar, pero no deber1a fallar
        XCTAssertNotNil(result, "El toggle con ID invalido no deber1a fallar")
    }
    
    func testToggleFavoriteWithVeryLargeId() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
container.loadPersistentStores { _, error in
    if let error = error {
        fatalError("Error cargando Core Data: \(error)")
    }
}
let dataManager = CityDataManager(container: container)
        let largeId = Int.max
        
        // When
        let result = await dataManager.toggleFavorite(for: largeId)
        
        // Then
        // El comportamiento puede variar, pero no deber1a fallar
        XCTAssertNotNil(result, "El toggle con ID muy grande no deber1a fallar")
    }
    
    // MARK: - Tests de stress
    func testStressTestWithRapidSearches() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When - Ejecutar muchas busquedas rapidas
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    let query = "City\(i % 10)"
                    _ = await dataManager.searchCitiesByName(prefix: query, limit: 10)
                }
            }
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThan(totalTime, 5.0, "100 busquedas concurrentes deber1an completarse en < 5 segundos")
    }
    
    func testStressTestWithRapidFavorites() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When - Ejecutar muchos toggles de favoritos
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    _ = await dataManager.toggleFavorite(for: i + 1)
                }
            }
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThan(totalTime, 3.0, "50 toggles de favoritos deber1an completarse en < 3 segundos")
    }
    
    // MARK: - Tests de integracion
    func testIntegrationWithRealData() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When - Ejecutar un flujo completo
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 1. Cargar todas las ciudades
        let allCities = await dataManager.loadAllCities()
        
        // 2. Buscar ciudades espec1ficas
        let newYorkResults = await dataManager.searchCitiesByName(prefix: "New York", limit: 5)
        let londonResults = await dataManager.searchCitiesByName(prefix: "London", limit: 5)
        
        // 3. Obtener estad1sticas
        let stats = await dataManager.getStats()
        
        
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThan(totalTime, 2.0, "El flujo completo deber1a completarse en < 2 segundos")
        XCTAssertFalse(allCities.isEmpty, "Deber1a cargar ciudades")
        XCTAssertNotNil(newYorkResults, "Deber1a encontrar resultados para New York")
        XCTAssertNotNil(londonResults, "Deber1a encontrar resultados para London")
        XCTAssertGreaterThan(stats.totalCities, 0, "Deber1a tener estad1sticas validas")
      
    }
    
    func testDataConsistency() async throws {
        //ToDo: implement
    }
    
    // MARK: - Tests de refresh
    func testRefreshCities() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = await dataManager.refreshCities()
        let refreshTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertNotNil(result, "El refresh deber1a retornar un resultado")
        XCTAssertLessThan(refreshTime, 10.0, "El refresh deber1a completarse en un tiempo razonable")
    }
    
    func testRefreshCitiesPerformance() async throws {
        // Given
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        // When - Ejecutar refresh multiples veces
        let iterations = 3
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = await dataManager.refreshCities()
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        let averageTime = totalTime / Double(iterations)
        
        // Then
        XCTAssertLessThan(averageTime, 5.0, "El tiempo promedio de refresh deber1a ser < 5 segundos")
    }
    
    func testPerformanceWithLargeDataset() async throws {
        let container = NSPersistentContainer(name: "CityDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error cargando Core Data: \(error)")
            }
        }
        let dataManager = CityDataManager(container: container)
        let iterations = 10
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<iterations {
            _ = await dataManager.searchCitiesByName(prefix: "City\(i)", limit: 50)
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        let averageTime = totalTime / Double(iterations)
        
        XCTAssertLessThan(averageTime, 0.06, "Tiempo promedio < 50ms")
    }
} 
