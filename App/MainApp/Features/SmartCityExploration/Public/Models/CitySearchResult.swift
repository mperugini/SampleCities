//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

/// Public model for city search results
public struct CitySearchResult: Sendable, Identifiable, Equatable {
    public let id: Int
    public let name: String
    public let country: String
    public let coordinate: Coordinate
    
    public struct Coordinate: Sendable, Equatable {
        public let latitude: Double
        public let longitude: Double
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    public init(id: Int, name: String, country: String, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.country = country
        self.coordinate = coordinate
    }
}

/// Feature events for external communication
public enum SmartCityExplorationEvent: Sendable {
    case citySelected(CitySearchResult)
    case favoriteToggled(CitySearchResult, isFavorite: Bool)
    case searchPerformed(query: String, resultCount: Int)
}
