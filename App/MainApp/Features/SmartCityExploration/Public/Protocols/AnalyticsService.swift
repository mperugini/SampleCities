//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

public protocol AnalyticsService: Sendable {
    func track(_ event: String, parameters: [String: Any])
} 
