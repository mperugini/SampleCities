//
//  AppContainer.swift
//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation
import UIKit

@MainActor
final class AppContainer {
    static let shared = AppContainer()
    
    // MARK: - Lazy Dependencies
    private lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack()
    }()
    
    private lazy var analyticsService: AnalyticsService = {
        return AnalyticsServiceImpl()
    }()
    
    private lazy var networkService: NetworkService = {
        return NetworkService()
    }()
    
    private lazy var coreDataService: CoreDataService = {
        return CoreDataService(persistentContainer: self.coreDataStack.persistentContainer)
    }()
    
    private lazy var localDataSource: LocalDataSource = {
        return LocalDataSourceImpl(coreDataStack: coreDataStack)
    }()
    
    // Actor no puede ser lazy var en @MainActor class, se crea cuando se necesita
    private var _dataManager: CityDataManager?
    
    private var optDataManager: CityDataManager {
        if let existing = _dataManager {
            return existing
        }
        // print("[AppContainer] Creating CityDataManager...")
        // uso una config de cache optimizada para el entorno de desarrollo
        let cacheConfig = CacheConfiguration.generous
        let manager = CityDataManager(
            container: self.coreDataStack.persistentContainer, 
            networkService: networkService,
            cacheConfiguration: cacheConfig
        )
        _dataManager = manager
        return manager
    }
    
    private lazy var cityRepository: CityRepository = {
        return CityRepositoryImpl(
            dataManager: optDataManager
        )
    }()
    
    private lazy var searchIndex: CitySearchIndex = {
        return CitySearchIndex()
    }()
    
    private lazy var performanceMonitor: SearchPerformanceMonitor = {
        return SimpleSearchPerformanceMonitor()
    }()
    
    private lazy var searchUseCase: SearchCityUseCase = {
        return SearchCityUseCaseImpl(
            repository: cityRepository,
            searchIndex: searchIndex
        )
    }()
    
    private lazy var favoritesUseCase: FavoriteCitiesUseCase = {
        return FavoriteCitiesUseCaseImpl(repository: cityRepository)
    }()
    
    private lazy var statsService: StatsService = {
        return StatsServiceImpl(coreDataStack: self.coreDataStack)
    }()
    
    private lazy var errorLogger: ErrorLogger = {
        return SmartCityErrorLogger(analyticsService: analyticsService)
    }()
    
    private lazy var appDependencies: AppDependencies = {
        return AppDependencies()
    }()
    
    private lazy var config: SmartCityExplorationConfig = {
        // print("[AppContainer] Creating SmartCityExplorationConfig...")
        return SmartCityExplorationConfig(
            maxSearchResults: 50,
            enableOfflineMode: true,
            analyticsEnabled: true
        )
    }()
    
    private init() {
        // print("[AppContainer] Initializing...")
    }
    
    // MARK: - Resolution Methods
    
    func resolve<T>(_ type: T.Type) -> T {
     
        if T.self == CoreDataStack.self {
            return coreDataStack as! T
        } else if T.self == AnalyticsService.self {
            return analyticsService as! T
        } else if T.self == NetworkService.self {
            return networkService as! T
        } else if T.self == CoreDataService.self {
            return coreDataService as! T
        } else if T.self == CityRepository.self {
            return cityRepository as! T
        } else if T.self == CitySearchIndex.self {
            return searchIndex as! T
        } else if T.self == SearchPerformanceMonitor.self {
            return performanceMonitor as! T
        } else if T.self == CityDataManager.self {
            return optDataManager as! T
        } else if T.self == SearchCityUseCase.self {
            return searchUseCase as! T
        } else if T.self == FavoriteCitiesUseCase.self {
            return favoritesUseCase as! T
        } else if T.self == StatsService.self {
            return statsService as! T
        } else if T.self == ErrorLogger.self {
            return errorLogger as! T
        } else if T.self == AppDependencies.self {
            return appDependencies as! T
        } else if T.self == SmartCityExplorationConfig.self {
            return config as! T
        } else {
            // print("[AppContainer] Unsupported type: \(T.self)")
            // print("[AppContainer] Type description: \(String(describing: T.self))")
            // print("[AppContainer] Type identity: \(ObjectIdentifier(T.self))")
           
            let error = UnknownError(underlying: NSError(domain: "AppContainer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported type: \(T.self)"]))
             print("[AppContainer] Error: \(error)")
            // ToDo: Track handled exception
            // Retornar un valor por defecto o nil si es posible
            // Para este caso, como no podemos retornar nil, lanzamos el error
            // El código que llama a este método debería manejar el error
            return T.self as! T // Esto fallara en runtime pero de forma controlada
        }
    }
    
    // MARK: - Feature Dependencies
    
    func createSmartCityDependencies(presentingViewController: UIViewController) -> SmartCityExplorationDependencies {
        // print("[AppContainer] Creating SmartCityDependencies...")
        return SmartCityDependencyAdapter(
            appDependencies: appDependencies,
            presentingViewController: presentingViewController
        )
    }
    
    func createSmartCityFeature(presentingViewController: UIViewController) -> SmartCityExplorationFeature {
        return SmartCityExplorationFeatureImpl(
            config: config,
            dependencies: createSmartCityDependencies(presentingViewController: presentingViewController),
            coreDataStack: coreDataStack
        )
    }
    
    // MARK: - Public Accessors
    
    var publicStatsService: StatsService {
        return statsService
    }
    
    var publicErrorLogger: ErrorLogger {
        return errorLogger
    }
    
    var publicAnalyticsService: AnalyticsService {
        return analyticsService
    }
    
    // MARK: - Index Building
    
    func buildSearchIndex() async {
        // [AppContainer] Building search index...
        let cities = await optDataManager.loadCitiesWithDownload()
        if !cities.isEmpty {
            await searchIndex.buildIndex(from: cities)
            // [AppContainer] Search index built successfully with \(cities.count) cities
        } else {
            // [AppContainer] No cities found to build search index
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        // print("[AppContainer] Cleaning up...")
        // To implement cleanup
    }
}
