//
//  AppDependencies.swift
//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit

public final class AppDependencies {
    public lazy var analytics: AnalyticsService = AnalyticsServiceImpl()
    
    public init() {}
}

// Analytics implementation
final class AnalyticsServiceImpl: AnalyticsService {
    func track(_ event: String, parameters: [String: Any]) {
        // print("Track: \(event), params: \(parameters)")
        // ToDo: Implement Firebase Analytics
    }
}

// Navigation implementation
@MainActor
final class NavigationServiceImpl: NavigationService {
    private weak var rootViewController: UIViewController?
    
    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    func present(_ viewController: UIViewController, animated: Bool) {
        rootViewController?.present(viewController, animated: animated)
    }
    
    func dismiss(animated: Bool) {
        rootViewController?.dismiss(animated: animated)
    }
}


