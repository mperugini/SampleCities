//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import CoreData
import MapKit

// MARK: - City Model
public struct City: Codable, Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let country: String
    public let coord: Coordinate
    public let isFavorite: Bool
    
    var searchCoordinate: CitySearchResult.Coordinate {
        CitySearchResult.Coordinate(latitude: coord.lat, longitude: coord.lon)
    }
    
    public struct Coordinate: Codable, Equatable, Hashable, Sendable {
        public let lon: Double
        public let lat: Double
        
        public init(lon: Double, lat: Double) {
            self.lon = lon
            self.lat = lat
        }
    }
    
    public init(id: Int, name: String, country: String, coord: Coordinate, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.country = country
        self.coord = coord
        self.isFavorite = isFavorite
    }
    
    // Convenience initializer from Core Data entity
    public init(from entity: NSManagedObject) {
        self.id = Int(entity.value(forKey: "id") as? Int32 ?? 0)
        self.name = entity.value(forKey: "name") as? String ?? ""
        self.country = entity.value(forKey: "country") as? String ?? ""
        
        // Handle both NSNumber and Double for coordinates
        let longitudeValue = entity.value(forKey: "longitude")
        let latitudeValue = entity.value(forKey: "latitude")
        
        let longitude: Double
        let latitude: Double
        
        if let number = longitudeValue as? NSNumber {
            longitude = number.doubleValue
        } else {
            longitude = longitudeValue as? Double ?? 0.0
        }
        
        if let number = latitudeValue as? NSNumber {
            latitude = number.doubleValue
        } else {
            latitude = latitudeValue as? Double ?? 0.0
        }
        
        self.coord = Coordinate(lon: longitude, lat: latitude)
        self.isFavorite = entity.value(forKey: "isFavorite") as? Bool ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case country
        case coord
        case isFavorite
    }
    
    func toPublicModel() -> CitySearchResult {
        CitySearchResult(
            id: id,
            name: name,
            country: country,
            coordinate: searchCoordinate
        )
    }
}

// MARK: - MapKit Annotation
public class CityAnnotation: NSObject, MKAnnotation, Identifiable {
    public let city: City
    public var id: Int { city.id }
    
    public init(city: City) {
        self.city = city
        super.init()
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon)
    }
    
    public var title: String? {
        city.name
    }
    
    public var subtitle: String? {
        city.country
    }
}
