//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit

/// Dependencies required by the feature
public protocol SmartCityExplorationDependencies {
    var analyticsService: any AnalyticsService { get }
    var navigationService: any NavigationService { get }
}




