import Foundation
/*
// MARK: - Compressed Radix Trie Node
private final class TrieNode: @unchecked Sendable {
    var children: [Character: TrieNode] = [:]
    var cities: [City] = []
    var isEndOfWord = false
    var prefix: String = ""
    
    init() {}
}

// MARK: - Compressed Radix Trie
public final class CompressedRadixTrie: Sendable {
    private let root = TrieNode()
    private let maxResults: Int
    private let queue = DispatchQueue(label: "com.smartcity.trie", qos: .userInitiated)
    
    public init(maxResults: Int = 50) {
        self.maxResults = maxResults
    }
    
    // MARK: - Public Interface
    
    public func insert(_ city: City) {
        queue.async {
            self._insert(city)
        }
    }
    
    public func search(prefix: String) async -> [City] {
        await withCheckedContinuation { continuation in
            queue.async {
                let results = self._search(prefix: prefix.lowercased())
                continuation.resume(returning: results)
            }
        }
    }
    
    public func clear() {
        queue.async {
            self._clear()
        }
    }
    
    public func getStats() async -> TrieStats {
        await withCheckedContinuation { continuation in
            queue.async {
                let stats = self._getStats()
                continuation.resume(returning: stats)
            }
        }
    }
    
    public func buildIndex(from cities: [City]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self._clear() // Clear existing index
                for city in cities {
                    self._insert(city)
                }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Private Implementation
    
    private func _insert(_ city: City) {
        let name = city.name.lowercased()
        var current = root
        
        for char in name {
            if current.children[char] == nil {
                current.children[char] = TrieNode()
            }
            current = current.children[char]!
        }
        
        current.isEndOfWord = true
        current.cities.append(city)
        
        // Keep only the most relevant cities (limit memory usage)
        if current.cities.count > maxResults {
            current.cities = Array(current.cities.prefix(maxResults))
        }
        
   
    }
    
    private func _search(prefix: String) -> [City] {

        var current = root
        
        // Navigate to the prefix node
        for char in prefix {
            guard let nextNode = current.children[char] else {
                //ToDo: evaluate if tracking or handled exception is needed for tihis case
                return [] // Prefix not found
            }
            current = nextNode
        }
        
        // Collect all cities from this node and its descendants
        var results: [City] = []
        collectCities(from: current, results: &results)
        

        // For single character prefixes, show some sample cities
        if prefix.count == 1 && !results.isEmpty {
            let sampleCities = results.prefix(5).map { $0.name }
            // print("[CompressedRadixTrie] Sample cities for prefix '\(prefix)': \(sampleCities)")
        }
        
        // Sort by relevance (exact matches first, luego por nombre y pa1s)
        let sortedResults = results.sorted { city1, city2 in
            let name1 = city1.name.lowercased()
            let name2 = city2.name.lowercased()
            let country1 = city1.country.lowercased()
            let country2 = city2.country.lowercased()
            
            // Exact prefix matches primero
            let exact1 = name1.hasPrefix(prefix)
            let exact2 = name2.hasPrefix(prefix)
            if exact1 != exact2 {
                return exact1
            }
            // Luego por nombre
            if name1 != name2 {
                return name1 < name2
            }
            // Finalmente por pa1s (orden descendente)
            return country1 > country2
        }.prefix(maxResults).map { $0 }

        // Filtra los duplicados por ciudad, pa1s y coordenadas
        var uniqueSet = Set<String>()
        let uniqueResults = sortedResults.filter { city in
            let key = "\(city.name.lowercased())|\(city.country.lowercased())|\(city.coordinate.longitude)|\(city.coordinate.latitude)"
            if uniqueSet.contains(key) {
                return false
            } else {
                uniqueSet.insert(key)
                return true
            }
        }

        return Array(uniqueResults)
    }
    
    private func collectCities(from node: TrieNode, results: inout [City]) {
        results.append(contentsOf: node.cities)

        for child in node.children.values {
            collectCities(from: child, results: &results)
        }
    }
    
    private func _clear() {
        root.children.removeAll()
        root.cities.removeAll()
        root.isEndOfWord = false
    }
    
    private func _getStats() -> TrieStats {
        var totalNodes = 0
        var totalCities = 0
        var maxDepth = 0
        
        func countNodes(_ node: TrieNode, depth: Int) {
            totalNodes += 1
            totalCities += node.cities.count
            maxDepth = max(maxDepth, depth)
            
            for child in node.children.values {
                countNodes(child, depth: depth + 1)
            }
        }
        
        countNodes(root, depth: 0)
        
        return TrieStats(
            totalNodes: totalNodes,
            totalCities: totalCities,
            maxDepth: maxDepth,
            memoryUsage: estimateMemoryUsage()
        )
    }
    
    private func estimateMemoryUsage() -> Int {
        // Rough estimation: each node ~100 bytes, each city ~200 bytes
        var totalNodes = 0
        var totalCities = 0
        
        func count(_ node: TrieNode) {
            totalNodes += 1
            totalCities += node.cities.count
            
            for child in node.children.values {
                count(child)
            }
        }
        
        count(root)
        
        return totalNodes * 100 + totalCities * 200
    }
}

// MARK: - Trie Statistics
public struct TrieStats: Sendable {
    public let totalNodes: Int
    public let totalCities: Int
    public let maxDepth: Int
    public let memoryUsage: Int
    
    public var memoryUsageMB: Double {
        Double(memoryUsage) / 1024 / 1024
    }
}

// MARK: - Performance Search Result
public struct OptimizedSearchResult: Sendable {
    public let cities: [City]
    public let searchTime: TimeInterval
    public let source: String
    public let trieStats: TrieStats?
    
    public init(cities: [City], searchTime: TimeInterval, source: String, trieStats: TrieStats? = nil) {
        self.cities = cities
        self.searchTime = searchTime
        self.source = source
        self.trieStats = trieStats
    }
} 

*/
