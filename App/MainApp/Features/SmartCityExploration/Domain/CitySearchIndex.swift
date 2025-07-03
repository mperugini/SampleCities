//
//  CitySearchIndex.swift
//  SmartCityExploration
//
//  Created by Mariano Peruginoi on 02/07/2025.
//

// Trie implementation for fast prefix search
public actor CitySearchIndex {
    private struct IndexEntry {
        let cityId: Int
        let normalizedName: String
        let originalName: String
        let country: String
        let coord: City.Coordinate
    }
    
    private var entries: [IndexEntry] = []
    private var sortedIndices: [Int] = []
    private var isBuilt = false
    
    public init() {}
    
    public func buildIndex(from cities: [City]) async {
        // Build entries
        entries = cities.map { city in
            let combined = "\(city.name) \(city.country)"
            let normalized = combined
                .lowercased()
                .folding(options: .diacriticInsensitive, locale: nil)

            return IndexEntry(
                cityId: city.id,
                normalizedName: normalized,
                originalName: city.name,
                country: city.country,
                coord: city.coord
            )
        }
        
        // Sort indices by normalized name
        sortedIndices = Array(0..<entries.count).sorted { i, j in
            entries[i].normalizedName < entries[j].normalizedName
        }
        
        isBuilt = true
    }
    
    public func search(prefix: String, maxResults: Int = 50) -> [City] {
        let normalizedPrefix = prefix.lowercased().folding(options: .diacriticInsensitive, locale: nil)
        
        guard isBuilt else {
            return []
        }
        
        var results: [City] = []
        var count = 0
        
        // Para prefijos cortos (menos de 4 letras), usar busqueda lineal
        if normalizedPrefix.count < 4 {
            var checkedCount = 0
            for index in sortedIndices {
                let entry = entries[index]
                checkedCount += 1
                if entry.normalizedName.hasPrefix(normalizedPrefix) {
                    if count >= maxResults {
                        break
                    }
                    results.append(City(
                        id: entry.cityId,
                        name: entry.originalName,
                        country: entry.country,
                        coord: entry.coord
                    ))
                    count += 1
                }
                if checkedCount % 100 == 0 {
                }
            }
        } else {
            // Para prefijos largos, usar busqueda binaria
            
            // Binary search for the first possible index in sortedIndices
            var left = 0
            var right = sortedIndices.count - 1
            var startIndex = sortedIndices.count
            
            while left <= right {
                let mid = (left + right) / 2
                let entryIndex = sortedIndices[mid]
                let entry = entries[entryIndex]
                
                if entry.normalizedName.hasPrefix(normalizedPrefix) {
                    startIndex = mid
                    right = mid - 1
                } else if entry.normalizedName < normalizedPrefix {
                    left = mid + 1
                } else {
                    right = mid - 1
                }
            }
            
            // Si no encontro ningun match exacto, startIndex sera sortedIndices.count
            if startIndex == sortedIndices.count {
                startIndex = left
            }
            
            // Collect results from binary search
            for i in startIndex..<sortedIndices.count {
                let entryIndex = sortedIndices[i]
                let entry = entries[entryIndex]
                if !entry.normalizedName.hasPrefix(normalizedPrefix) {
                    break
                }
                if count >= maxResults {
                    break
                }
                results.append(City(
                    id: entry.cityId,
                    name: entry.originalName,
                    country: entry.country,
                    coord: entry.coord
                ))
                count += 1
            }
            
            // Si no encontro resultados con binaria, hacer busqueda lineal como fallback
            if results.isEmpty {
                for index in sortedIndices {
                    let entry = entries[index]
                    if entry.normalizedName.hasPrefix(normalizedPrefix) {
                        if count >= maxResults {
                            break
                        }
                        results.append(City(
                            id: entry.cityId,
                            name: entry.originalName,
                            country: entry.country,
                            coord: entry.coord
                        ))
                        count += 1
                    }
                }
            }
        }
        
        return results
    }
}
