//
//  SmartCityExplorationFeatureImpl.swift
//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit

final class SmartCityExplorationFeatureImpl: SmartCityExplorationFeature {
    private let config: SmartCityExplorationConfig
    private let dependencies: any SmartCityExplorationDependencies
    private let coreDataStack: CoreDataStack
    
    init(config: SmartCityExplorationConfig, dependencies: any SmartCityExplorationDependencies, coreDataStack: CoreDataStack) {
        self.config = config
        self.dependencies = dependencies
        self.coreDataStack = coreDataStack
    }
    
    @MainActor
    func start(from context: FeatureContext) async {
        let coordinator = SmartCityCoordinator(
            navigationService: dependencies.navigationService,
            dependencies: dependencies
        )
        coordinator.start()
    }
}
