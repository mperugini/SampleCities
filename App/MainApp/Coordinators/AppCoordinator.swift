//
//  AppCoordinator.swift
//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import UIKit
import SwiftUI

@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let container: AppContainer
    private var activeFeatures: [String: Any] = [:]
    private var mainViewController: UIViewController?
    
    init(window: UIWindow) {
        self.window = window
        self.container = AppContainer.shared
    }
    
    func start() {
        let mainVC = createMainViewController()
        self.mainViewController = mainVC
        
        let navController = UINavigationController(rootViewController: mainVC)
        navController.navigationBar.prefersLargeTitles = true
        
        window.rootViewController = navController
    }
    
    private func createMainViewController() -> UIViewController {
        let statsService = container.publicStatsService
        
        let homeView = MainHomeView(
            statsService: statsService,
            onSmartCityExplorationTapped: {
                Task {
                    await self.startSmartCityExploration()
                }
            }
        )
        
        let hostingController = UIHostingController(rootView: homeView)
        hostingController.title = "Main App"
        
        return hostingController
    }
    
    func startSmartCityExploration() async {
        guard let presentingVC = mainViewController else { return }
        
        // Create the feature with the current view controller
        let feature = container.createSmartCityFeature(presentingViewController: presentingVC)
        
        activeFeatures["smartCity"] = feature
        
        let context = FeatureContext(
            presentationStyle: .modal,
            userInfo: ["source": "main_screen"]
        )
        
        await feature.start(from: context)
    }
}
