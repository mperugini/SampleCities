//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit

public protocol NavigationService: Sendable {
    @MainActor func present(_ viewController: UIViewController, animated: Bool)
    @MainActor func dismiss(animated: Bool)
} 
