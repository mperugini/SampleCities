//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

public final class FavoriteCitiesUseCaseImpl: FavoriteCitiesUseCase {
    private let repository: CityRepository
    
    public init(repository: CityRepository) {
        self.repository = repository
    }
    
    public func getFavorites() async -> Result<[City], Error> {
        return await repository.getFavoriteCities()
    }
    
    public func toggleFavorite(_ city: City) async {
        let result = await repository.toggleFavorite(city)
        
        switch result {
        case .success:
            // Successfully toggled favorite status
            break
        case .failure(let error):
            // Log error but don't throw to avoid breaking UI
             print("[FavoriteCitiesUseCaseImpl] Error toggling favorite for city \(city.id): \(error)")
            //ToDo: track handled exception
        }
    }
    
    public func isFavorite(_ city: City) async -> Bool {
        let result = await repository.getFavoriteCities()
        
        switch result {
        case .success(let favorites):
            return favorites.contains { $0.id == city.id }
        case .failure(let error):
             print("[FavoriteCitiesUseCaseImpl] Error checking favorite status for city \(city.id): \(error)")
            return false
        }
    }
} 
