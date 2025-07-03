//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

public protocol LocalDataSource: Sendable {
    func saveCities(_ cities: [City]) async throws
    func getAllCities() async -> Result<[City], Error>
    func getFavoriteCities() async -> Result<[City], Error>
    func toggleFavorite(_ city: City) async throws
} 
