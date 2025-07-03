//
//  NetworkService.swift
//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

// MARK: - Network Models
public struct CityResponse: Codable, Sendable {
    public let country: String
    public let name: String
    public let id: Int
    public let coord: Coordinate
    
    public init(country: String, name: String, id: Int, coord: Coordinate) {
        self.country = country
        self.name = name
        self.id = id
        self.coord = coord
    }
    
    private enum CodingKeys: String, CodingKey {
        case country, name, coord
        case id = "_id"
    }
}

public struct Coordinate: Codable, Sendable {
    public let lon: Double
    public let lat: Double
    
    public init(lon: Double, lat: Double) {
        self.lon = lon
        self.lat = lat
    }
}

// MARK: - Network Service Protocol
public protocol NetworkServiceProtocol: Sendable {
    func downloadCities() async throws -> [CityResponse]
}

// MARK: - Network Service Implementation
public actor NetworkService: NetworkServiceProtocol {
    private let session = URLSession.shared
    
    //FixMe: Esta url no deberia estar aca, incluso deberia descargar resultados paginados para mejorar la experiencia del usuario, indicando que aun se estan descargando ciudades pero ya pudiendo bucar
    
    private let citiesURL = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")!
    
    public init() {}
    
    public func downloadCities() async throws -> [CityResponse] {
        // print("[NetworkService] Starting download from: \(citiesURL)")
        
        let (data, response) = try await session.data(from: citiesURL)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            // print("[NetworkService] Invalid HTTP response type")
            throw NetworkError.invalidResponse
        }
        
        // print("[NetworkService] HTTP Status: \(httpResponse.statusCode)")
        
        guard 200...299 ~= httpResponse.statusCode else {
            // print("[NetworkService] HTTP Error: \(httpResponse.statusCode)")
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let cities = try decoder.decode([CityResponse].self, from: data)

        return cities
    }
}
