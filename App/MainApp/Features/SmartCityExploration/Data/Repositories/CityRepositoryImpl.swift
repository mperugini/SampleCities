//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

public final class CityRepositoryImpl: CityRepository {
    private let dataManager: CityDataManager
    
    public init(dataManager: CityDataManager) {
        self.dataManager = dataManager
    }
    
    public func loadCities() async -> Result<[City], Error> {
        let cities = await dataManager.loadCitiesWithDownload()
        if !cities.isEmpty {
            return .success(cities)
        } else {
            return .failure(DataError.dataNotFound)
        }
    }
    
    public func getFavoriteCities() async -> Result<[City], Error> {
        let favorites = await dataManager.getFavoriteCities()
        return .success(favorites)
    }
    
    public func toggleFavorite(_ city: City) async -> Result<Void, Error> {
        let success = await dataManager.toggleFavorite(for: city.id)
        return success ? .success(()) : .failure(DataError.storageFailed(underlying: NSError(domain: "CityDataManager", code: 1)))
    }
    
    public func refreshCities() async -> Result<Void, Error> {
        let success = await dataManager.refreshCities()
        return success ? .success(()) : .failure(DataError.storageFailed(underlying: NSError(domain: "CityDataManager", code: 2)))
    }
}
