//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

@MainActor
public protocol SearchCityUseCase {
    func search(prefix: String) async -> Result<[City], Error>
    func loadCities() async -> Result<[City], Error>
    func refreshCities() async -> Result<Void, Error>
} 
