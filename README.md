# SmartCityExploration - iOS App

Una aplicación iOS para explorar y buscar ciudades con funcionalidades avanzadas de búsqueda, mapas interactivos y información meteorológica en tiempo real.

##  Características Principales

###  Búsqueda Inteligente de Ciudades
- **Búsqueda en tiempo real** con debouncing de 300ms
- **Índice de búsqueda optimizado** usando algoritmos de búsqueda binaria y lineal
- **Soporte para diacríticos** y búsqueda insensible a mayúsculas/minúsculas
- **Límite de resultados** configurable (20 por defecto)
- **Cache inteligente** con políticas LRU/LFU/FIFO

### Visualización de Mapas
- **MapKit integrado** con marcadores
- **Soporte para orientación** (Portrait/Landscape)
- **Split View** en iPad y landscape
- **Navegación fluida** entre lista y detalle

### Información Meteorológica
- **API de OpenWeather** integrada
- **Cache local** para evitar recargas innecesarias
- **Información en tiempo real**: temperatura, humedad, descripción
- **Overlay visual** en mapas

###  Sistema de Favoritos
- **Persistencia local** con Core Data, idealmente deberia estar en la nube aociada a un usuario
- **Toggle de favoritos** con feedback visual

###  Experiencia de Usuario
- **Navegación adaptativa** según orientación del dispositivo
- **Interfaz responsive** con SwiftUI
- **Animaciones fluidas** y transiciones
- **Accesibilidad** (WIP)

##  Arquitectura

### Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│  Views (SwiftUI) │ ViewModels │ Coordinators               │
│  • SmartCitySearchView                                       │
│  • CityDetailView                                            │
│  • CityMapView                                               │
│  • WeatherOverlayView                                        │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  UseCases │ Entities │ Repositories │ Services              │
│  • SearchCityUseCase                                         │
│  • FavoriteCitiesUseCase                                     │
│  • CitySearchIndex                                           │
│  • CompressedRadixTrie (WIP)                                       │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  Repositories │ DataSources │ Network │ CoreData            │
│  • CityRepositoryImpl                                       │
│  • CityDataManager                                          │
│  • NetworkService                                           │
│  • WeatherService                                           │
└─────────────────────────────────────────────────────────────┘
```

### Componentes Principales

#### Domain Layer
- **City**: Modelo de dominio principal
- **UseCases**: Lógica de negocio
- **CitySearchIndex**: Índice de búsqueda
- **CompressedRadixTrie**: Estructura de datos para búsqueda rápida (WIP)

####  Data Layer
- **CityDataManager**: Actor para gestión de datos con cache
- **NetworkService**: Descarga de ciudades desde API
- **WeatherService**: Información meteorológica
- **CoreDataStack**: Persistencia local

####  Presentation Layer
- **SmartCitySearchView**: Vista principal con navegación adaptativa
- **CitySearchViewModel**: ViewModel con lógica de búsqueda
- **CityDetailView**: Vista de detalle con mapa
- **WeatherOverlayView**: Overlay meteorológico

##  Tecnologías Utilizadas

### Core Technologies
- **Swift 6** con async/await
- **SwiftUI** para la interfaz de usuario
- **MapKit** para mapas interactivos
- **Core Data** para persistencia

### Performance & Optimization
- **Actors** para concurrencia segura
- **Cache** con métricas
- **Índices de búsqueda** 
- **Debouncing** para búsquedas
- **Lazy loading** de datos

### External APIs
- **OpenWeather API** para datos meteorológicos
- **Cities JSON** para datos de ciudades

##  Funcionalidades 

### iPhone
- **Portrait**: Lista de búsqueda → Navegación push a detalle
- **Landscape**: Split view con lista y mapa

##  Configuración

### Requisitos
- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

### Instalación
1. Clonar el repositorio
2. Abrir `SmartCityExploration.xcodeproj`
3. Configurar el scheme
4. Build y ejecutar

### Configuración de APIs
- **OpenWeather API**: Configurada en `WeatherService.swift`
- **Cities API**: Endpoint configurado en `NetworkService.swift`

##  Testing

### Cobertura de Tests
- **Unit Tests**: UseCases, ViewModels, Data Managers (WIP)
- **Performance Tests**: Búsqueda y cache
- **UI Tests**: Navegación y interacciones (WIP)

### Ejecutar Tests
```bash
xcodebuild test -project SmartCityExploration.xcodeproj -scheme SmartCityExploration
```

##  Métricas y Observabilidad

### Performance Monitoring
- **Search Performance**: Tiempo de búsqueda y resultados
- **Cache Metrics**: Hit rate, evictions, memory usage
- **Network Performance**: Latencia de descarga

### Analytics
- **User Interactions**: Búsquedas, selecciones, favoritos
- **Error Tracking**: Errores de red y datos
- **Usage Patterns**: Patrones de uso de la app

##  Flujo de Datos

### Búsqueda de Ciudades
1. Usuario escribe en search bar
2. Debouncing de 300ms
3. Validación de entrada
4. Búsqueda en índice
5. Cache de resultados
6. Actualización de UI

### Carga de Datos
1. Verificar cache local
2. Cargar desde Core Data
3. Si no hay datos, descargar desde API
4. Guardar en Core Data
5. Construir índice de búsqueda

### Información Meteorológica
1. Selección de ciudad
2. Verificar cache local
3. Si no está en cache, llamar a OpenWeather API
4. Guardar en cache
5. Mostrar overlay en mapa

##  Optimizaciones Implementadas

### Performance
- **Cache inteligente** con políticas de eviccion
- **Índices de búsqueda** optimizados, probando Trie vs array indexado
- **Búsqueda binaria** para prefijos largos
- **Búsqueda lineal** para prefijos cortos
- **Debouncing** para evitar llamadas innecesarias

### Memoria
- **Límites de cache** configurables
- **Estimación de memoria** en tiempo real
- **Cleanup** de recursos no utilizados

### UX
- **Navegación adaptativa** según orientación
- **Estados de carga** con feedback visual
- **Manejo de errores** sin crashes
- **Animaciones fluidas** y transiciones

## Roadmap

### Próximas Funcionalidades
- [ ] **Offline Mode**: Funcionalidad completa sin conexión
- [ ] **Filtros Avanzados**: Por país, por favoritos, por localización, etc.
- [ ] **Historial de Búsquedas**: Persistencia de últimas búsquedas 
- [ ] **Sincronización**: Favoritos en la nube
- [ ] **Voice**: Busqueda por voz
- [ ] **Accesibility**: implementar navegacion con accesibilidad


### Mejoras Técnicas
- [ ] **SwiftData**: Migración desde Core Data
- [ ] **Swift Concurrency**: Más uso de actors y async/await
- [ ] **Performance Profiling**: Métricas más detalladas
- [ ] **Accessibility**: Mejoras de accesibilidad

##  Contribución

### Guidelines
- Seguir la arquitectura Clean Architecture
- Mantener cobertura de tests > 80%
- Documentar cambios importantes

### Code Style
- **Swift 6** con async/await
- **SwiftUI** para UI
- **Actors** para concurrencia
- **Protocols** para abstracción

## Licencia

Este proyecto es parte de un challenge técnico para Mobile Technical Lead.

---
