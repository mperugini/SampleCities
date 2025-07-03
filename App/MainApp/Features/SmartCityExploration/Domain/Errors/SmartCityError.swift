//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import Foundation

// MARK: - Error Domain
public enum SmartCityErrorDomain: String, CaseIterable {
    case domain = "Domain"
    case data = "Data"
    case network = "Network"
    case presentation = "Presentation"
    case storage = "Storage"
    case search = "Search"
    case unknown = "Unknown"
}

// MARK: - Base Error Protocol
public protocol SmartCityError: LocalizedError, CustomStringConvertible {
    var domain: SmartCityErrorDomain { get }
    var code: Int { get }
    var userMessage: String { get }
    var technicalDetails: String? { get }
    var underlyingError: Error? { get }
}

// MARK: - Domain Errors
public enum DomainError: SmartCityError {
    case invalidCityData(reason: String)
    case searchQueryTooShort(minLength: Int)
    case searchQueryTooLong(maxLength: Int)
    case invalidSearchParameters
    case cityNotFound(name: String)
    case favoriteLimitExceeded(limit: Int)
    
    public var domain: SmartCityErrorDomain { .domain }
    
    public var code: Int {
        switch self {
        case .invalidCityData: return 1001
        case .searchQueryTooShort: return 1002
        case .searchQueryTooLong: return 1003
        case .invalidSearchParameters: return 1004
        case .cityNotFound: return 1005
        case .favoriteLimitExceeded: return 1006
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidCityData(let reason):
            return "Datos de ciudad invalidos: \(reason)"
        case .searchQueryTooShort(let minLength):
            return "La busqueda debe tener al menos \(minLength) caracteres"
        case .searchQueryTooLong(let maxLength):
            return "La busqueda no puede exceder \(maxLength) caracteres"
        case .invalidSearchParameters:
            return "Parametros de busqueda invalidos"
        case .cityNotFound(let name):
            return "Ciudad '\(name)' no encontrada"
        case .favoriteLimitExceeded(let limit):
            return "L1mite de favoritos excedido (\(limit) maximo)"
        }
    }
    
    public var userMessage: String {
        switch self {
        case .invalidCityData:
            return "Los datos de la ciudad no son validos"
        case .searchQueryTooShort(let minLength):
            return "Ingresa al menos \(minLength) caracteres para buscar"
        case .searchQueryTooLong(let maxLength):
            return "La busqueda es demasiado larga (maximo \(maxLength) caracteres)"
        case .invalidSearchParameters:
            return "Parametros de busqueda incorrectos"
        case .cityNotFound(let name):
            return "No encontramos la ciudad '\(name)'"
        case .favoriteLimitExceeded(let limit):
            return "Ya tienes \(limit) ciudades favoritas. Elimina alguna para agregar mas."
        }
    }
    
    public var technicalDetails: String? {
        switch self {
        case .invalidCityData(let reason):
            return "Invalid city data: \(reason)"
        case .searchQueryTooShort(let minLength):
            return "Search query too short. Minimum length: \(minLength)"
        case .searchQueryTooLong(let maxLength):
            return "Search query too long. Maximum length: \(maxLength)"
        case .invalidSearchParameters:
            return "Invalid search parameters provided"
        case .cityNotFound(let name):
            return "City '\(name)' not found in database"
        case .favoriteLimitExceeded(let limit):
            return "Favorite limit exceeded. Current limit: \(limit)"
        }
    }
    
    public var underlyingError: Error? { nil }
    
    public var description: String {
        return "[\(domain.rawValue)] \(errorDescription ?? "Unknown error") (Code: \(code))"
    }
}

// MARK: - Data Errors
public enum DataError: SmartCityError {
    case coreDataError(underlying: Error)
    case dataCorruption
    case invalidDataFormat
    case dataMigrationFailed
    case entityNotFound(entityName: String)
    case saveFailed(reason: String)
    case deleteFailed(reason: String)
    case fetchFailed(reason: String)
    case dataNotFound
    case decodingFailed(underlying: Error)
    case storageFailed(underlying: Error)
    
    public var domain: SmartCityErrorDomain { .data }
    
    public var code: Int {
        switch self {
        case .coreDataError: return 2001
        case .dataCorruption: return 2002
        case .invalidDataFormat: return 2003
        case .dataMigrationFailed: return 2004
        case .entityNotFound: return 2005
        case .saveFailed: return 2006
        case .deleteFailed: return 2007
        case .fetchFailed: return 2008
        case .dataNotFound: return 2009
        case .decodingFailed: return 2010
        case .storageFailed: return 2011
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .coreDataError(let underlying):
            return "Error de Core Data: \(underlying.localizedDescription)"
        case .dataCorruption:
            return "Los datos estan corruptos"
        case .invalidDataFormat:
            return "Formato de datos invalido"
        case .dataMigrationFailed:
            return "Fallo la migracion de datos"
        case .entityNotFound(let entityName):
            return "Entidad '\(entityName)' no encontrada"
        case .saveFailed(let reason):
            return "Error al guardar: \(reason)"
        case .deleteFailed(let reason):
            return "Error al eliminar: \(reason)"
        case .fetchFailed(let reason):
            return "Error al obtener datos: \(reason)"
        case .dataNotFound:
            return "Datos no encontrados"
        case .decodingFailed(let underlying):
            return "Error al decodificar datos: \(underlying.localizedDescription)"
        case .storageFailed(let underlying):
            return "Error al almacenar datos: \(underlying.localizedDescription)"
        }
    }
    
    public var userMessage: String {
        switch self {
        case .coreDataError:
            return "Error interno de la aplicacion"
        case .dataCorruption:
            return "Los datos de la aplicacion estan dañados"
        case .invalidDataFormat:
            return "Formato de datos incorrecto"
        case .dataMigrationFailed:
            return "Error al actualizar la aplicacion"
        case .entityNotFound:
            return "Informacion no encontrada"
        case .saveFailed:
            return "No se pudo guardar la informacion"
        case .deleteFailed:
            return "No se pudo eliminar la informacion"
        case .fetchFailed:
            return "No se pudieron cargar los datos"
        case .dataNotFound:
            return "No se encontraron los datos solicitados"
        case .decodingFailed:
            return "Error al procesar los datos"
        case .storageFailed:
            return "No se pudo guardar la informacion"
        }
    }
    
    public var technicalDetails: String? {
        switch self {
        case .coreDataError(let underlying):
            return "Core Data error: \(underlying)"
        case .dataCorruption:
            return "Data corruption detected"
        case .invalidDataFormat:
            return "Invalid data format"
        case .dataMigrationFailed:
            return "Data migration failed"
        case .entityNotFound(let entityName):
            return "Entity '\(entityName)' not found"
        case .saveFailed(let reason):
            return "Save failed: \(reason)"
        case .deleteFailed(let reason):
            return "Delete failed: \(reason)"
        case .fetchFailed(let reason):
            return "Fetch failed: \(reason)"
        case .dataNotFound:
            return "Data not found"
        case .decodingFailed(let underlying):
            return "Decoding failed: \(underlying)"
        case .storageFailed(let underlying):
            return "Storage failed: \(underlying)"
        }
    }
    
    public var underlyingError: Error? {
        switch self {
        case .coreDataError(let underlying):
            return underlying
        case .decodingFailed(let underlying):
            return underlying
        case .storageFailed(let underlying):
            return underlying
        default:
            return nil
        }
    }
    
    public var description: String {
        return "[\(domain.rawValue)] \(errorDescription ?? "Unknown error") (Code: \(code))"
    }
}

// MARK: - Network Errors
public enum NetworkError: SmartCityError {
    case noInternetConnection
    case timeout(duration: TimeInterval)
    case serverError(statusCode: Int)
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited(retryAfter: TimeInterval?)
    
    public var domain: SmartCityErrorDomain { .network }
    
    public var code: Int {
        switch self {
        case .noInternetConnection: return 3001
        case .timeout: return 3002
        case .serverError: return 3003
        case .invalidResponse: return 3004
        case .unauthorized: return 3005
        case .forbidden: return 3006
        case .notFound: return 3007
        case .rateLimited: return 3008
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "Sin conexion a internet"
        case .timeout(let duration):
            return "Tiempo de espera agotado (\(Int(duration))s)"
        case .serverError(let statusCode):
            return "Error del servidor (\(statusCode))"
        case .invalidResponse:
            return "Respuesta del servidor invalida"
        case .unauthorized:
            return "No autorizado"
        case .forbidden:
            return "Acceso prohibido"
        case .notFound:
            return "Recurso no encontrado"
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                return "Demasiadas solicitudes. Intenta en \(Int(retryAfter))s"
            } else {
                return "Demasiadas solicitudes"
            }
        }
    }
    
    public var userMessage: String {
        switch self {
        case .noInternetConnection:
            return "Verifica tu conexion a internet e intenta nuevamente"
        case .timeout:
            return "La conexion tardo demasiado. Intenta nuevamente"
        case .serverError:
            return "Error en el servidor. Intenta mas tarde"
        case .invalidResponse:
            return "Error en la respuesta del servidor"
        case .unauthorized:
            return "Sesion expirada. Inicia sesion nuevamente"
        case .forbidden:
            return "No tienes permisos para esta accion"
        case .notFound:
            return "La informacion solicitada no esta disponible"
        case .rateLimited:
            return "Demasiadas solicitudes. Espera un momento"
        }
    }
    
    public var technicalDetails: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection available"
        case .timeout(let duration):
            return "Request timeout after \(duration) seconds"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .invalidResponse:
            return "Invalid server response format"
        case .unauthorized:
            return "Unauthorized access (401)"
        case .forbidden:
            return "Forbidden access (403)"
        case .notFound:
            return "Resource not found (404)"
        case .rateLimited(let retryAfter):
            return "Rate limited. Retry after: \(retryAfter?.description ?? "unknown")"
        }
    }
    
    public var underlyingError: Error? { nil }
    
    public var description: String {
        return "[\(domain.rawValue)] \(errorDescription ?? "Unknown error") (Code: \(code))"
    }
}

// MARK: - Search Errors
public enum SearchError: SmartCityError {
    case indexNotReady
    case searchEngineNotInitialized
    case invalidSearchPattern
    case searchTimeout
    case indexCorruption
    
    public var domain: SmartCityErrorDomain { .search }
    
    public var code: Int {
        switch self {
        case .indexNotReady: return 4001
        case .searchEngineNotInitialized: return 4002
        case .invalidSearchPattern: return 4003
        case .searchTimeout: return 4004
        case .indexCorruption: return 4005
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .indexNotReady:
            return "1ndice de busqueda no esta listo"
        case .searchEngineNotInitialized:
            return "Motor de busqueda no inicializado"
        case .invalidSearchPattern:
            return "Patron de busqueda invalido"
        case .searchTimeout:
            return "Busqueda agoto el tiempo de espera"
        case .indexCorruption:
            return "1ndice de busqueda corrupto"
        }
    }
    
    public var userMessage: String {
        switch self {
        case .indexNotReady:
            return "La busqueda no esta disponible en este momento"
        case .searchEngineNotInitialized:
            return "Error interno de busqueda"
        case .invalidSearchPattern:
            return "Busqueda no valida"
        case .searchTimeout:
            return "La busqueda tardo demasiado"
        case .indexCorruption:
            return "Error en el sistema de busqueda"
        }
    }
    
    public var technicalDetails: String? {
        switch self {
        case .indexNotReady:
            return "Search index not ready"
        case .searchEngineNotInitialized:
            return "Search engine not initialized"
        case .invalidSearchPattern:
            return "Invalid search pattern"
        case .searchTimeout:
            return "Search operation timed out"
        case .indexCorruption:
            return "Search index corruption detected"
        }
    }
    
    public var underlyingError: Error? { nil }
    
    public var description: String {
        return "[\(domain.rawValue)] \(errorDescription ?? "Unknown error") (Code: \(code))"
    }
}

// MARK: - Storage Errors
public enum StorageError: SmartCityError {
    case saveFailed(reason: String)
    case loadFailed(reason: String)
    case deleteFailed(reason: String)
    case keyNotFound(key: String)
    case invalidData(key: String)
    case quotaExceeded
    
    public var domain: SmartCityErrorDomain { .storage }
    
    public var code: Int {
        switch self {
        case .saveFailed: return 5001
        case .loadFailed: return 5002
        case .deleteFailed: return 5003
        case .keyNotFound: return 5004
        case .invalidData: return 5005
        case .quotaExceeded: return 5006
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed(let reason):
            return "Error al guardar: \(reason)"
        case .loadFailed(let reason):
            return "Error al cargar: \(reason)"
        case .deleteFailed(let reason):
            return "Error al eliminar: \(reason)"
        case .keyNotFound(let key):
            return "Clave '\(key)' no encontrada"
        case .invalidData(let key):
            return "Datos invalidos para la clave '\(key)'"
        case .quotaExceeded:
            return "Cuota de almacenamiento excedida"
        }
    }
    
    public var userMessage: String {
        switch self {
        case .saveFailed:
            return "No se pudo guardar la informacion"
        case .loadFailed:
            return "No se pudo cargar la informacion"
        case .deleteFailed:
            return "No se pudo eliminar la informacion"
        case .keyNotFound:
            return "Informacion no encontrada"
        case .invalidData:
            return "Datos corruptos"
        case .quotaExceeded:
            return "Espacio de almacenamiento insuficiente"
        }
    }
    
    public var technicalDetails: String? {
        switch self {
        case .saveFailed(let reason):
            return "Save failed: \(reason)"
        case .loadFailed(let reason):
            return "Load failed: \(reason)"
        case .deleteFailed(let reason):
            return "Delete failed: \(reason)"
        case .keyNotFound(let key):
            return "Key '\(key)' not found"
        case .invalidData(let key):
            return "Invalid data for key '\(key)'"
        case .quotaExceeded:
            return "Storage quota exceeded"
        }
    }
    
    public var underlyingError: Error? { nil }
    
    public var description: String {
        return "[\(domain.rawValue)] \(errorDescription ?? "Unknown error") (Code: \(code))"
    }
}

// MARK: - Error Factory
public struct SmartCityErrorFactory {
    public static func create(from error: Error) -> SmartCityError {
        // Si ya es un SmartCityError, devolverlo tal como esta
        if let smartCityError = error as? SmartCityError {
            return smartCityError
        }
        
        // Mapear errores de Core Data
        if let coreDataError = error as? NSError {
            switch coreDataError.domain {
            case NSCocoaErrorDomain:
                return DataError.coreDataError(underlying: error)
            default:
                break
            }
        }
        
        // Mapear errores de red
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return NetworkError.noInternetConnection
            case .timedOut:
                return NetworkError.timeout(duration: 30.0)
            case .cannotFindHost, .cannotConnectToHost:
                return NetworkError.serverError(statusCode: 0)
            default:
                return NetworkError.invalidResponse
            }
        }
        
        // Error desconocido
        return UnknownError(underlying: error)
    }
}

// MARK: - Unknown Error
public struct UnknownError: SmartCityError {
    public let underlying: Error
    
    public init(underlying: Error) {
        self.underlying = underlying
    }
    
    public var domain: SmartCityErrorDomain { .unknown }
    public var code: Int { 9999 }
    
    public var errorDescription: String? {
        return "Error desconocido: \(underlying.localizedDescription)"
    }
    
    public var userMessage: String {
        return "Ocurrio un error inesperado"
    }
    
    public var technicalDetails: String? {
        return "Unknown error: \(underlying)"
    }
    
    public var underlyingError: Error? { underlying }
    
    public var description: String {
        return "[\(domain.rawValue)] \(errorDescription ?? "Unknown error") (Code: \(code))"
    }
} 
