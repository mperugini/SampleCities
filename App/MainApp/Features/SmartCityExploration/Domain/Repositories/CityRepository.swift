//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

public protocol CityRepository: Sendable {
    func loadCities() async -> Result<[City], Error>
    func getFavoriteCities() async -> Result<[City], Error>
    func toggleFavorite(_ city: City) async -> Result<Void, Error>
    func refreshCities() async -> Result<Void, Error>
} 
