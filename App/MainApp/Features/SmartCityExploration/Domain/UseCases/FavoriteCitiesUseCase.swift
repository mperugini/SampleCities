//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

@MainActor
public protocol FavoriteCitiesUseCase {
    func getFavorites() async -> Result<[City], Error>
    func toggleFavorite(_ city: City) async
    func isFavorite(_ city: City) async -> Bool
} 
