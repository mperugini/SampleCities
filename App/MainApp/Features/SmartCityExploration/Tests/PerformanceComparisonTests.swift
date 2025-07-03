//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

/*
import XCTest
@testable import SmartCityExploration

final class PerformanceComparisonTests: XCTestCase {
    
    // MARK: - Test de comparacion completa de rendimiento
    
    func testCompletePerformanceComparison() async throws {
        
        // Given - Dataset de prueba
        let datasetSizes = [200000]
        
        for size in datasetSizes {
            
            let cities = (1...size).map { i in
                City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
            }
            
            // Test CompressedRadixTrie
            let trie = CompressedRadixTrie()
            let trieBuildStart = CFAbsoluteTimeGetCurrent()
            await trie.buildIndex(from: cities)
            let trieBuildTime = CFAbsoluteTimeGetCurrent() - trieBuildStart
            
            let trieMemoryBefore = getMemoryUsage()
            let trieSearchStart = CFAbsoluteTimeGetCurrent()
            for i in 0..<100 {
                _ = await trie.search(prefix: "City\(i % 1000)")
            }
            let trieSearchTime = CFAbsoluteTimeGetCurrent() - trieSearchStart
            let trieMemoryAfter = getMemoryUsage()
            let trieMemoryUsed = trieMemoryAfter - trieMemoryBefore
            
            // Test CitySearchIndex
            let searchIndex = CitySearchIndex()
            let searchIndexBuildStart = CFAbsoluteTimeGetCurrent()
            await searchIndex.buildIndex(from: cities)
            let searchIndexBuildTime = CFAbsoluteTimeGetCurrent() - searchIndexBuildStart
            
            let searchIndexMemoryBefore = getMemoryUsage()
            let searchIndexSearchStart = CFAbsoluteTimeGetCurrent()
            for i in 0..<100 {
                _ = await searchIndex.search(prefix: "City\(i % 1000)", maxResults: 10)
            }
            let searchIndexSearchTime = CFAbsoluteTimeGetCurrent() - searchIndexSearchStart
            let searchIndexMemoryAfter = getMemoryUsage()
            let searchIndexMemoryUsed = searchIndexMemoryAfter - searchIndexMemoryBefore
            
            // Results
            // print("  CompressedRadixTrie:")
            // print("    - Construccion: \(String(format: "%.3f", trieBuildTime))s")
            // print("    - Busqueda (100 queries): \(String(format: "%.3f", trieSearchTime))s")
            // print("    - Memoria: \(String(format: "%.1f", trieMemoryUsed)) MB")
            
            // print("  CitySearchIndex:")
            // print("    - Construccion: \(String(format: "%.3f", searchIndexBuildTime))s")
            // print("    - Busqueda (100 queries): \(String(format: "%.3f", searchIndexSearchTime))s")
            // print("    - Memoria: \(String(format: "%.1f", searchIndexMemoryUsed)) MB")
            
            let buildRatio = searchIndexBuildTime / trieBuildTime
            let searchRatio = searchIndexSearchTime / trieSearchTime
            let memoryRatio = searchIndexMemoryUsed / trieMemoryUsed
            
            // print("  Ratios (CitySearchIndex/CompressedRadixTrie):")
            // print("    - Construccion: \(String(format: "%.2f", buildRatio))x")
            // print("    - Busqueda: \(String(format: "%.2f", searchRatio))x")
            // print("    - Memoria: \(String(format: "%.2f", memoryRatio))x")
            
            // Assertions
            XCTAssertLessThan(trieBuildTime, 5.0, "CompressedRadixTrie construccion deber1a ser rapida")
            XCTAssertLessThan(searchIndexBuildTime, 5.0, "CitySearchIndex construccion deber1a ser rapida")
            XCTAssertLessThan(trieSearchTime, 30.0, "CompressedRadixTrie busqueda deber1a ser rapida")
            XCTAssertLessThan(searchIndexSearchTime, 30.0, "CitySearchIndex busqueda deber1a ser rapida")
        }
    }
    
    // MARK: - Test de concurrencia
    
    func testConcurrencyComparison() async throws {
        // print("Probando rendimiento concurrente...")
        
        // Given
        let cities = (1...20000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        let trie = CompressedRadixTrie()
        let searchIndex = CitySearchIndex()
        
        await trie.buildIndex(from: cities)
        await searchIndex.buildIndex(from: cities)
        
        // When - Busquedas concurrentes
        let concurrentSearches = 200
        
        // Test CompressedRadixTrie
        let trieStartTime = CFAbsoluteTimeGetCurrent()
        await withTaskGroup(of: [City].self) { group in
            for i in 0..<concurrentSearches {
                group.addTask {
                    await trie.search(prefix: "city\(i % 1000)")
                }
            }
        }
        let trieConcurrentTime = CFAbsoluteTimeGetCurrent() - trieStartTime
        
        // Test CitySearchIndex
        let searchIndexStartTime = CFAbsoluteTimeGetCurrent()
        await withTaskGroup(of: [City].self) { group in
            for i in 0..<concurrentSearches {
                group.addTask {
                    await searchIndex.search(prefix: "City\(i % 1000)", maxResults: 10)
                }
            }
        }
        let searchIndexConcurrentTime = CFAbsoluteTimeGetCurrent() - searchIndexStartTime
        
        // Results
        // print("  Busquedas concurrentes (\(concurrentSearches) queries):")
        // print("    - CompressedRadixTrie: \(String(format: "%.3f", trieConcurrentTime))s")
        // print("    - CitySearchIndex: \(String(format: "%.3f", searchIndexConcurrentTime))s")
        // print("    - Ratio: \(String(format: "%.2f", searchIndexConcurrentTime / trieConcurrentTime))x")
        
        XCTAssertLessThan(trieConcurrentTime, 10.0, "CompressedRadixTrie concurrente deber1a ser rapido")
        XCTAssertLessThan(searchIndexConcurrentTime, 10.0, "CitySearchIndex concurrente deber1a ser rapido")
    }
    
    // MARK: - Test de precision
    
    func testAccuracyComparison() async throws {
        // print("🎯 Probando precision de busqueda...")
        
        // Given
        let cities = [
            City(id: 1, name: "New York", country: "USA", coord: City.Coordinate(lon: -74.0060, lat: 40.7128)),
            City(id: 2, name: "New Orleans", country: "USA", coord: City.Coordinate(lon: -90.0715, lat: 29.9511)),
            City(id: 3, name: "Newcastle", country: "UK", coord: City.Coordinate(lon: -1.6178, lat: 54.9783)),
            City(id: 4, name: "London", country: "UK", coord: City.Coordinate(lon: -0.1278, lat: 51.5074)),
            City(id: 5, name: "Paris", country: "France", coord: City.Coordinate(lon: 2.3522, lat: 48.8566)),
            City(id: 6, name: "Tokyo", country: "Japan", coord: City.Coordinate(lon: 139.6503, lat: 35.6762))
        ]
        
        let trie = CompressedRadixTrie()
        let searchIndex = CitySearchIndex()
        
        await trie.buildIndex(from: cities)
        await searchIndex.buildIndex(from: cities)
        
        // Test queries
        let testQueries = ["New", "London", "Paris", "Tokyo", "X", ""]
        
        for query in testQueries {
            let trieResults = await trie.search(prefix: query.lowercased())
            let searchIndexResults = await searchIndex.search(prefix: query, maxResults: 10)
            
            XCTAssertEqual(trieResults.count, searchIndexResults.count, 
                          "Ambos 1ndices deber1an retornar el mismo numero de resultados para '\(query)'")
            
            let trieNames = Set(trieResults.map { $0.name })
            let searchIndexNames = Set(searchIndexResults.map { $0.name })
            
            XCTAssertEqual(trieNames, searchIndexNames, 
                          "Ambos 1ndices deber1an retornar los mismos resultados para '\(query)'")
            
            // print("  Query '\(query)': \(trieResults.count) resultados - Coinciden")
        }
    }
    
    // MARK: - Test de memoria bajo presion
    
    func testMemoryPressureTest() async throws {
        // print(" Probando uso de memoria bajo presion...")
        
        // Given
        let largeDataset = (1...200000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        // Test CompressedRadixTrie
        let trieMemoryBefore = getMemoryUsage()
        let trie = CompressedRadixTrie()
        await trie.buildIndex(from: largeDataset)
        let trieMemoryAfter = getMemoryUsage()
        let trieMemoryUsed = trieMemoryAfter - trieMemoryBefore
        
        // Test CitySearchIndex
        let searchIndexMemoryBefore = getMemoryUsage()
        let searchIndex = CitySearchIndex()
        await searchIndex.buildIndex(from: largeDataset)
        let searchIndexMemoryAfter = getMemoryUsage()
        let searchIndexMemoryUsed = searchIndexMemoryAfter - searchIndexMemoryBefore
        
        // print("  Memoria usada (200k ciudades):")
        // print("    - CompressedRadixTrie: \(String(format: "%.1f", trieMemoryUsed)) MB")
        // print("    - CitySearchIndex: \(String(format: "%.1f", searchIndexMemoryUsed)) MB")
        // print("    - Ratio: \(String(format: "%.2f", searchIndexMemoryUsed / trieMemoryUsed))x")
        
        // Verificar que ambos funcionan despues de la construccion
        let trieResults = await trie.search(prefix: "city1")
        let searchIndexResults = await searchIndex.search(prefix: "City1", maxResults: 10)
        
        XCTAssertFalse(trieResults.isEmpty, "CompressedRadixTrie deber1a funcionar despues de construccion")
        XCTAssertFalse(searchIndexResults.isEmpty, "CitySearchIndex deber1a funcionar despues de construccion")
        
        XCTAssertLessThan(trieMemoryUsed, 500.0, "CompressedRadixTrie no deber1a usar demasiada memoria")
        XCTAssertLessThan(searchIndexMemoryUsed, 500.0, "CitySearchIndex no deber1a usar demasiada memoria")
    }
    
    // MARK: - Test de recomendacion
    
    func testRecommendationBasedOnPerformance() async throws {
  
        // Given - Dataset realista
        let cities = (1...50000).map { i in
            City(id: i, name: "City\(i)", country: "Country\(i)", coord: City.Coordinate(lon: Double(i), lat: Double(i)))
        }
        
        let trie = CompressedRadixTrie()
        let searchIndex = CitySearchIndex()
        
        // Medir construccion
        let trieBuildStart = CFAbsoluteTimeGetCurrent()
        await trie.buildIndex(from: cities)
        let trieBuildTime = CFAbsoluteTimeGetCurrent() - trieBuildStart
        
        let searchIndexBuildStart = CFAbsoluteTimeGetCurrent()
        await searchIndex.buildIndex(from: cities)
        let searchIndexBuildTime = CFAbsoluteTimeGetCurrent() - searchIndexBuildStart
        
        // Medir busqueda
        let trieSearchStart = CFAbsoluteTimeGetCurrent()
        for i in 0..<1000 {
            _ = await trie.search(prefix: "city\(i % 1000)")
        }
        let trieSearchTime = CFAbsoluteTimeGetCurrent() - trieSearchStart
        
        let searchIndexSearchStart = CFAbsoluteTimeGetCurrent()
        for i in 0..<1000 {
            _ = await searchIndex.search(prefix: "City\(i % 1000)", maxResults: 10)
        }
        let searchIndexSearchTime = CFAbsoluteTimeGetCurrent() - searchIndexSearchStart
        
        // Medir memoria
        let trieMemoryBefore = getMemoryUsage()
        await trie.buildIndex(from: cities)
        let trieMemoryAfter = getMemoryUsage()
        let trieMemoryUsed = trieMemoryAfter - trieMemoryBefore
        
        let searchIndexMemoryBefore = getMemoryUsage()
        await searchIndex.buildIndex(from: cities)
        let searchIndexMemoryAfter = getMemoryUsage()
        let searchIndexMemoryUsed = searchIndexMemoryAfter - searchIndexMemoryBefore
        
        // Calcular scores
        let trieBuildScore = 1.0 / trieBuildTime
        let searchIndexBuildScore = 1.0 / searchIndexBuildTime
        let trieSearchScore = 1.0 / trieSearchTime
        let searchIndexSearchScore = 1.0 / searchIndexSearchTime
        let trieMemoryScore = 1.0 / trieMemoryUsed
        let searchIndexMemoryScore = 1.0 / searchIndexMemoryUsed
        
        let trieTotalScore = trieBuildScore + trieSearchScore + trieMemoryScore
        let searchIndexTotalScore = searchIndexBuildScore + searchIndexSearchScore + searchIndexMemoryScore
        
        // print("  puntuacion de performance:")
        // print("    - CompressedRadixTrie: \(String(format: "%.2f", trieTotalScore))")
        // print("    - CitySearchIndex: \(String(format: "%.2f", searchIndexTotalScore))")
        
        if trieTotalScore > searchIndexTotalScore {
            // print("  recomendacion: CompressedRadixTrie tiene mejor performance")
        } else {
            // print("  recomendacion: CitySearchIndex tiene mejor performance")
        }
        
        // Assertions para verificar que ambos son viables
        XCTAssertLessThan(trieBuildTime, 15.0, "CompressedRadixTrie construccion deberia ser razonable")
        XCTAssertLessThan(searchIndexBuildTime, 15.0, "CitySearchIndex construccion deberia ser razonable")
        XCTAssertLessThan(trieSearchTime, 15.0, "CompressedRadixTrie busqueda deberia ser rapida")
        XCTAssertLessThan(searchIndexSearchTime, 15.0, "CitySearchIndex busqueda deberia ser rapida")
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
