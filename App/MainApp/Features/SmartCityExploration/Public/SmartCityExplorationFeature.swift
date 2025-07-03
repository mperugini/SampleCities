//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit

/// Main entry point for Smart City Exploration feature
public protocol SmartCityExplorationFeature {
    /// Start the feature flow
    @MainActor
    func start(from context: FeatureContext) async
}

/// Feature context for navigation
public struct FeatureContext: Sendable {
    public enum PresentationStyle: Sendable {
        case modal
        case push
        case embedded(UIView)
    }
    
    public let presentationStyle: PresentationStyle
    public let userInfo: [String: String]
    
    public init(presentationStyle: PresentationStyle, userInfo: [String: String] = [:]) {
        self.presentationStyle = presentationStyle
        self.userInfo = userInfo
    }
}

/// Feature configuration
public struct SmartCityExplorationConfig: Sendable {
    public let maxSearchResults: Int
    public let enableOfflineMode: Bool
    public let analyticsEnabled: Bool
    
    public init(
        maxSearchResults: Int = 50,
        enableOfflineMode: Bool = true,
        analyticsEnabled: Bool = true
    ) {
        self.maxSearchResults = maxSearchResults
        self.enableOfflineMode = enableOfflineMode
        self.analyticsEnabled = analyticsEnabled
    }
}

/// Feature factory
public final class SmartCityExplorationFactory {
    public static func create(
        config: SmartCityExplorationConfig,
        dependencies: SmartCityExplorationDependencies,
        coreDataStack: CoreDataStack
    ) -> SmartCityExplorationFeature {
        SmartCityExplorationFeatureImpl(
            config: config,
            dependencies: dependencies,
            coreDataStack: coreDataStack
        )
    }
}
