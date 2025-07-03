//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

/*
import XCTest
@testable import SmartCityExploration

@MainActor
final class CompressedRadixTrieTests: XCTestCase {
    
    private var trie: CompressedRadixTrie!
    
    override func setUp() async throws {
        trie = CompressedRadixTrie()
    }
    
    override func tearDown() async throws {
        trie = nil
    }
    
    // MARK: - Tests basicos de insercion y busqueda
    
    func testBasicInsertionAndSearch() async throws {
        // Given
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511)),
            City(id: 3, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1278, lat: 51.5074))
        ]
        
        // When
        for city in cities {
            trie.insert(city)
        }
        let results = await trie.search(prefix: "new")
        
        // Then
        XCTAssertEqual(results.count, 2, "Deber1a encontrar 2 ciudades que empiecen con 'new'")
        XCTAssertTrue(results.allSatisfy { $0.name.lowercased().hasPrefix("new") })
    }
    
    func testEmptyTrieSearch() async throws {
        // Given
        let trie = CompressedRadixTrie()
        
        // When
        let results = await trie.search(prefix: "test")
        
        // Then
        XCTAssertTrue(results.isEmpty, "La busqueda en un trie vac1o deber1a retornar resultados vac1os")
    }
    
    func testCaseInsensitiveSearch() async throws {
        // Given
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        ]
        for city in cities {
            trie.insert(city)
        }
        
        // When
        let results1 = await trie.search(prefix: "new")
        let results2 = await trie.search(prefix: "NEW")
        let results3 = await trie.search(prefix: "New")
        
        // Then
        XCTAssertEqual(results1.count, results2.count, "Las busquedas deber1an ser case-insensitive")
        XCTAssertEqual(results1.count, results3.count, "Las busquedas deber1an ser case-insensitive")
    }
    
    // MARK: - Tests de l1mites
    func testMaxResultsLimit() async throws {
        // Given
        let trie = CompressedRadixTrie(maxResults: 2)
        let cities = (1...10).map { i in
            City(id: i, name: "City\(i)", country: "Country", coord: City.Coordinate(lon: 0.0, lat: 0.0))
        }
        
        // When
        for city in cities {
            trie.insert(city)
        }
        let results = await trie.search(prefix: "city")
        
        // Then
        XCTAssertLessThanOrEqual(results.count, 2, "Los resultados deber1an respetar el l1mite maximo")
    }
    
    func testZeroMaxResults() async throws {
        // Given
        let trie = CompressedRadixTrie(maxResults: 0)
        let cities = [
            City(id: 1, name: "Test", country: "Country", coord: City.Coordinate(lon: 0.0, lat: 0.0))
        ]
        
        // When
        for city in cities {
            trie.insert(city)
        }
        let results = await trie.search(prefix: "test")
        
        // Then
        XCTAssertTrue(results.isEmpty, "Con maxResults = 0, no deber1a retornar resultados")
    }
    
    
    
    func testWhitespacePrefixSearch() async throws {
        // Given
        let cities = [
            City(id: 1, name: "Test", country: "Country", coord: City.Coordinate(lon: 0.0, lat: 0.0))
        ]
        for city in cities {
            trie.insert(city)
        }
        
        // When
        let results = await trie.search(prefix: "   ")
        
        // Then
        XCTAssertTrue(results.isEmpty, "La busqueda con solo espacios deber1a retornar resultados vac1os")
    }
    
    func testVeryLongPrefixSearch() async throws {
        // Given
        let cities = [
            City(id: 1, name: "Test", country: "Country", coord: City.Coordinate(lon: 0.0, lat: 0.0))
        ]
        for city in cities {
            trie.insert(city)
        }
        
        // When
        let longPrefix = String(repeating: "a", count: 1000)
        let results = await trie.search(prefix: longPrefix)
        
        // Then
        XCTAssertTrue(results.isEmpty, "La busqueda con prefijo muy largo deber1a retornar resultados vac1os")
    }
    
    // MARK: - Tests de caracteres especiales
    func testSpecialCharacters() async throws {
        // Given
        let cities = [
            City(id: 1, name: "São Paulo", country: "Brazil", coord: City.Coordinate(lon: -46.6388, lat: -23.5505)),
            City(id: 2, name: "München", country: "Germany", coord: City.Coordinate(lon: 11.5820, lat: 48.1351))
        ]
        for city in cities {
            trie.insert(city)
        }
        
        // When
        let results = await trie.search(prefix: "são")
        
        // Then
        XCTAssertFalse(results.isEmpty, "Deber1a manejar caracteres especiales")
    }
    
    func testNumbersInNames() async throws {
        // Given
        let cities = [
            City(id: 1, name: "City123", country: "Country", coord: City.Coordinate(lon: 0.0, lat: 0.0)),
            City(id: 2, name: "123City", country: "Country", coord: City.Coordinate(lon: 0.0, lat: 0.0)),
            City(id: 3, name: "City456", country: "Country", coord: City.Coordinate(lon: 0.0, lat: 0.0))
        ]
        
        // When
        for city in cities {
            trie.insert(city)
        }
        let results1 = await trie.search(prefix: "city1")
        let results2 = await trie.search(prefix: "123")
        let results3 = await trie.search(prefix: "city4")
        
        // Then
        XCTAssertFalse(results1.isEmpty, "Deber1a manejar numeros en nombres")
        XCTAssertFalse(results2.isEmpty, "Deber1a manejar numeros en nombres")
        XCTAssertFalse(results3.isEmpty, "Deber1a manejar numeros en nombres")
    }
    
    // MARK: - Tests de stress
    func testStressTestWithRapidSearches() async throws {
        // Given
        let cities = (1...10000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        let localTrie = CompressedRadixTrie()
        for city in cities {
            localTrie.insert(city)
        }
        
        // When - Ejecutar muchas busquedas rapidas
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<1000 {
                group.addTask {
                    let prefix = "city\(i % 1000)"
                    _ = await localTrie.search(prefix: prefix)
                }
            }
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThan(totalTime, 1.5, "1000 busquedas concurrentes deber1an completarse en < 1.5 segundos")
    }
    
    func testRepeatedIndexRebuild() async throws {
        // Given
        let cities = (1...5000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        // When - Reconstruir el 1ndice multiples veces
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<10 {
            trie.clear()
            for city in cities {
                trie.insert(city)
            }
            _ = await trie.search(prefix: "city\(i * 100)")
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThan(totalTime, 5.0, "10 reconstrucciones del 1ndice deber1an completarse en < 5 segundos")
    }
    
    // MARK: - Tests de precision
    func testSearchAccuracy() async throws {
        // Given
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511)),
            City(id: 3, name: "Newcastle", country: "UK", coord: City.Coordinate(lon: -1.6178, lat: 54.9783)),
            City(id: 4, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1278, lat: 51.5074)),
            City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566))
        ]
        
        // When
        for city in cities {
            trie.insert(city)
        }
        let results = await trie.search(prefix: "new")
        
        // Then
        XCTAssertEqual(results.count, 3, "Deber1a encontrar exactamente 3 ciudades que empiecen con 'new'")
        
        let cityNames = Set(results.map { $0.name })
        let expectedNames = Set(["New York", "New Orleans", "Newcastle"])
        XCTAssertEqual(cityNames, expectedNames, "Deber1a encontrar las ciudades correctas")
    }
    
    // MARK: - Tests de performance
    func testLargeDatasetPerformance() async throws {
        // Given
        let cities = (1...10000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        // When
        let insertStartTime = CFAbsoluteTimeGetCurrent()
        for city in cities {
            trie.insert(city)
        }
        let insertTime = CFAbsoluteTimeGetCurrent() - insertStartTime
        
        let searchStartTime = CFAbsoluteTimeGetCurrent()
        let results = await trie.search(prefix: "city")
        let searchTime = CFAbsoluteTimeGetCurrent() - searchStartTime
        
        // Then
        XCTAssertLessThan(insertTime, 2.0, "La insercion de 10k ciudades deber1a ser rapida")
        XCTAssertLessThan(searchTime, 0.1, "La busqueda deber1a ser muy rapida")
        XCTAssertFalse(results.isEmpty, "Deber1a encontrar resultados")
    }
    
    func testMemoryUsage() async throws {
        // Given
        let initialMemory = getMemoryUsage()
        
        // When
        let cities = (1...10000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        for city in cities {
            trie.insert(city)
        }
        
        let afterInsertMemory = getMemoryUsage()
        let memoryIncrease = afterInsertMemory - initialMemory
        
        // Then
        XCTAssertLessThan(memoryIncrease, 100, "El uso de memoria deber1a ser razonable (< 100MB)")
        
        // Test that searches still work
        let results = await trie.search(prefix: "city1")
        XCTAssertFalse(results.isEmpty, "Las busquedas deber1an seguir funcionando")
    }
    
    // MARK: - Tests de comparacion con CitySearchIndex
    func testPerformanceComparisonWithCitySearchIndex() async throws {
        // Given
        let searchIndex = CitySearchIndex()
        
        let cities = (1...10000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        // When - Construir 1ndices
        let trieBuildStart = CFAbsoluteTimeGetCurrent()
        for city in cities {
            trie.insert(city)
        }
        let trieBuildTime = CFAbsoluteTimeGetCurrent() - trieBuildStart
        
        let searchIndexBuildStart = CFAbsoluteTimeGetCurrent()
        await searchIndex.buildIndex(from: cities)
        let searchIndexBuildTime = CFAbsoluteTimeGetCurrent() - searchIndexBuildStart
        
        // Then - Comparar tiempos de construccion
        // print("Tiempo de construccion CompressedRadixTrie: \(trieBuildTime) segundos")
        // print("Tiempo de construccion CitySearchIndex: \(searchIndexBuildTime) segundos")
        
        // Verificar que ambos 1ndices funcionan correctamente
        let trieResults = await trie.search(prefix: "city1")
        let searchIndexResults = await searchIndex.search(prefix: "City1", maxResults: 10)
        
        XCTAssertFalse(trieResults.isEmpty, "CompressedRadixTrie deber1a encontrar resultados")
        XCTAssertFalse(searchIndexResults.isEmpty, "CitySearchIndex deber1a encontrar resultados")
    }
    
    func testSearchPerformanceComparison() async throws {
        // Given
        let searchIndex = CitySearchIndex()
        
        let cities = (1...50000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        for city in cities {
            trie.insert(city)
        }
        await searchIndex.buildIndex(from: cities)
        
        // When - Comparar tiempos de busqueda
        let iterations = 1000
        let queries = (0..<iterations).map { "City\($0 % 1000)" }
        
        // Test CompressedRadixTrie
        let trieStartTime = CFAbsoluteTimeGetCurrent()
        for query in queries {
            _ = await trie.search(prefix: query.lowercased())
        }
        let trieSearchTime = CFAbsoluteTimeGetCurrent() - trieStartTime
        
        // Test CitySearchIndex
        let searchIndexStartTime = CFAbsoluteTimeGetCurrent()
        for query in queries {
            _ = await searchIndex.search(prefix: query, maxResults: 10)
        }
        let searchIndexSearchTime = CFAbsoluteTimeGetCurrent() - searchIndexStartTime
        
        // Then
        // print("Tiempo de busqueda CompressedRadixTrie: \(trieSearchTime) segundos")
        // print("Tiempo de busqueda CitySearchIndex: \(searchIndexSearchTime) segundos")
        // print("Ratio: \(searchIndexSearchTime / trieSearchTime)x")
        
        // Verificar que ambos son rapidos
        XCTAssertLessThan(trieSearchTime, 2.0, "CompressedRadixTrie deber1a ser rapido")
        XCTAssertLessThan(searchIndexSearchTime, 2.0, "CitySearchIndex deber1a ser rapido")
    }
    
    func testMemoryUsageComparison() async throws {
        // Given
        let searchIndex = CitySearchIndex()
        
        let cities = (1...100000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        // When - Construir 1ndices y medir memoria
        let trieMemoryBefore = getMemoryUsage()
        for city in cities {
            trie.insert(city)
        }
        let trieMemoryAfter = getMemoryUsage()
        let trieMemoryUsed = trieMemoryAfter - trieMemoryBefore
        
        let searchIndexMemoryBefore = getMemoryUsage()
        await searchIndex.buildIndex(from: cities)
        let searchIndexMemoryAfter = getMemoryUsage()
        let searchIndexMemoryUsed = searchIndexMemoryAfter - searchIndexMemoryBefore
        
        // Then
        // print("Memoria usada CompressedRadixTrie: \(trieMemoryUsed) MB")
        // print("Memoria usada CitySearchIndex: \(searchIndexMemoryUsed) MB")
        // print("Ratio de memoria: \(searchIndexMemoryUsed / trieMemoryUsed)x")
        
        // Verificar que ambos 1ndices funcionan
        let trieResults = await trie.search(prefix: "city1")
        let searchIndexResults = await searchIndex.search(prefix: "City1", maxResults: 10)
        
        XCTAssertFalse(trieResults.isEmpty, "CompressedRadixTrie deber1a funcionar despues de construccion")
        XCTAssertFalse(searchIndexResults.isEmpty, "CitySearchIndex deber1a funcionar despues de construccion")
    }
    
    func testConcurrentSearchPerformance() async throws {
        // Given
        let searchIndex = CitySearchIndex()
        let cities = (1...20000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        let localTrie = CompressedRadixTrie()
        for city in cities {
            localTrie.insert(city)
        }
        await searchIndex.buildIndex(from: cities)
        
        // When - Busquedas concurrentes
        let concurrentSearches = 100
        
        // Test CompressedRadixTrie concurrente
        let trieStartTime = CFAbsoluteTimeGetCurrent()
        await withTaskGroup(of: [City].self) { group in
            for i in 0..<concurrentSearches {
                group.addTask {
                    await localTrie.search(prefix: "city\(i % 1000)")
                }
            }
        }
        let trieConcurrentTime = CFAbsoluteTimeGetCurrent() - trieStartTime
        
        // Test CitySearchIndex concurrente
        let searchIndexStartTime = CFAbsoluteTimeGetCurrent()
        await withTaskGroup(of: [City].self) { group in
            for i in 0..<concurrentSearches {
                group.addTask {
                    await searchIndex.search(prefix: "City\(i % 1000)", maxResults: 10)
                }
            }
        }
        let searchIndexConcurrentTime = CFAbsoluteTimeGetCurrent() - searchIndexStartTime
        
        // Then
        // print("Tiempo concurrente CompressedRadixTrie: \(trieConcurrentTime) segundos")
        // print("Tiempo concurrente CitySearchIndex: \(searchIndexConcurrentTime) segundos")
        
        XCTAssertLessThan(trieConcurrentTime, 1.0, "Busquedas concurrentes en CompressedRadixTrie deber1an ser rapidas")
        XCTAssertLessThan(searchIndexConcurrentTime, 1.0, "Busquedas concurrentes en CitySearchIndex deber1an ser rapidas")
    }
    
    // MARK: - Tests de precision
    
    func testSearchAccuracyComparison() async throws {
        // Given
        let searchIndex = CitySearchIndex()
        
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511)),
            City(id: 3, name: "Newcastle", country: "UK", coord: City.Coordinate(lon: -1.6178, lat: 54.9783)),
            City(id: 4, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1278, lat: 51.5074)),
            City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566))
        ]
        
        for city in cities {
            trie.insert(city)
        }
        await searchIndex.buildIndex(from: cities)
        
        // When
        let trieResults = await trie.search(prefix: "new")
        let searchIndexResults = await searchIndex.search(prefix: "New", maxResults: 10)
        
        // Then
        XCTAssertEqual(trieResults.count, searchIndexResults.count, "Ambos 1ndices deber1an retornar el mismo numero de resultados")
        
        let trieNames = Set(trieResults.map { $0.name })
        let searchIndexNames = Set(searchIndexResults.map { $0.name })
        
        XCTAssertEqual(trieNames, searchIndexNames, "Ambos 1ndices deber1an retornar los mismos resultados")
    }
    
    // MARK: - Tests de edge cases
    
    func testVeryLongQueries() async throws {
        // Given
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128))
        ]
        for city in cities {
            trie.insert(city)
        }
        
        let longQuery = String(repeating: "a", count: 1000)
        
        // When
        let results = await trie.search(prefix: longQuery)
        
        // Then
        XCTAssertTrue(results.isEmpty, "Consultas muy largas deber1an retornar resultados vac1os")
    }
    
    // MARK: - Tests de stress
    
    func testStressTestWithLargeDataset() async throws {
        // Given
        let cities = (1...100000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        // When
        let buildStartTime = CFAbsoluteTimeGetCurrent()
        for city in cities {
            trie.insert(city)
        }
        let buildTime = CFAbsoluteTimeGetCurrent() - buildStartTime
        
        let searchStartTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<1000 {
            _ = await trie.search(prefix: "city\(i % 1000)")
        }
        let searchTime = CFAbsoluteTimeGetCurrent() - searchStartTime
        
        // Then
        XCTAssertLessThan(buildTime, 10.0, "Construccion del 1ndice deber1a ser eficiente")
        XCTAssertLessThan(searchTime, 5.0, "Busquedas deber1an ser rapidas")
        
        // print("Stress test - Construccion: \(buildTime)s, Busquedas: \(searchTime)s")
    }
}

// MARK: - Helper Functions

private func getMemoryUsage() -> Double {
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
        return Double(info.resident_size) / 1024.0 / 1024.0 // Convert to MB
    } else {
        return 0.0
    }
} 
*/
