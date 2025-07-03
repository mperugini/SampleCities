//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit

// MARK: - Smart City Dependencies Adapter
public struct SmartCityDependencyAdapter: SmartCityExplorationDependencies {
    private let appDependencies: AppDependencies
    private let presentingViewController: UIViewController
    
    public init(appDependencies: AppDependencies, presentingViewController: UIViewController) {
        self.appDependencies = appDependencies
        self.presentingViewController = presentingViewController
    }
    
    public var analyticsService: any AnalyticsService {
        SmartCityAnalyticsService()
    }

    public var navigationService: any NavigationService {
        SmartCityNavigationService(presentingViewController: presentingViewController)
    }
}

// MARK: - Simple Implementations
private struct SmartCityAnalyticsService: AnalyticsService {
    func track(_ event: String, parameters: [String: Any]) {
        // print("[Analytics] \(event): \(parameters)")
    }
}

private struct SmartCityNavigationService: NavigationService {
    private let presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func present(_ viewController: UIViewController, animated: Bool) {
        Task { @MainActor in
            presentingViewController.present(viewController, animated: animated)
        }
    }
    
    func dismiss(animated: Bool) {
        Task { @MainActor in
            presentingViewController.dismiss(animated: animated)
        }
    }
} 
