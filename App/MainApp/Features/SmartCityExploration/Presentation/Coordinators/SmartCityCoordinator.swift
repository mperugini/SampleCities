//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
final class SmartCityCoordinator: ObservableObject {
    private let navigationService: any NavigationService
    private let dependencies: any SmartCityExplorationDependencies
    private let container: AppContainer
    
    init(navigationService: any NavigationService, dependencies: any SmartCityExplorationDependencies) {
        self.navigationService = navigationService
        self.dependencies = dependencies
        self.container = AppContainer.shared
    }
    
    func start() {
        let viewModel = createViewModel()
        let view = SmartCitySearchView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.modalPresentationStyle = .fullScreen
        
        navigationService.present(hostingController, animated: true)
    }
    
    func stop() {
        navigationService.dismiss(animated: true)
    }
    
    private func createViewModel() -> CitySearchViewModel {
        // Resolve all dependencies from the container
        let searchUseCase = container.resolve(SearchCityUseCase.self)
        let favoritesUseCase = container.resolve(FavoriteCitiesUseCase.self)
        let analyticsService = dependencies.analyticsService
        let performanceMonitor = container.resolve(SearchPerformanceMonitor.self)
        let searchIndex = container.resolve(CitySearchIndex.self)
        
        return CitySearchViewModel(
            searchUseCase: searchUseCase,
            favoritesUseCase: favoritesUseCase,
            analyticsService: analyticsService,
            performanceMonitor: performanceMonitor,
            navigationService: navigationService,
            searchIndex: searchIndex
        )
    }
}
