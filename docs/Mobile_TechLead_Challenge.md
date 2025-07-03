# Smart City Exploration - Technical Design Document
## Mobile Technical Lead Challenge

**Versión:** 1.0  
**Fecha:** Julio 2025  
**Autor:** Mariano Perugini 
**Stakeholders:** Equipo de Desarrollo, Product Manager, IT Manager, UX 

---

## 1. Executive Summary

This document presents the complete technical solution for the "Smart City Exploration" feature, enabling users to explore and search cities using an interactive map with real-time optimized search.

### 1.1 Project Objectives
- Implement real-time search for 200,000+ cities (< 100ms)
- Deliver a smooth user experience with adaptive UI (portrait/landscape)
- Integrate interactive maps with weather information
- Establish a scalable architecture for future features

### 1.2 Success Metrics
- **Performance:** Search < 100ms for any prefix
- **UX:** UI response time < 16ms
- **Quality:** Test coverage > 80%
- **Adoption:** 70% active users in the first week

---


## 2. Technical Architecture

### 2.1 Architectural Decisions

#### 2.1.1 Clean Architecture + MVVM
**Decision:** Implement Clean Architecture with MVVM in the presentation layer.

**Rationale:**
- **Separation of concerns:** Enables independent testing of each layer
- **Scalability:** Facilitates adding new features without affecting existing code
- **Maintainability:** More readable and organized code
- **Delivery velocity:** Multiple developers can work in parallel

**Alternatives considered:**
- VIPER: Too complex for the current scope
- MVC: Not enough separation for testing

#### 2.1.2 SearchIndex for Optimized Search
**Decision:** Implement a hybrid index (SearchIndex) using linear search for short prefixes (<4 chars) and binary search for longer prefixes, over a sorted array of normalized names.

**Rationale:**
- **Adaptive performance:** O(n) for short prefixes (few results, low impact), O(log n) for long prefixes (binary search)
- **Memory efficient:** Only stores sorted indices and normalized data, no complex structures
- **Scalability:** Maintains acceptable performance with 200k+ cities
- **Maintainability:** Easy for any team member to understand and modify
- **User experience:** Instant search and alphabetically sorted results

**Alternatives considered:**
- Array + filter: O(n) - unacceptable for 200k records
- Binary Search Tree: O(log n) - good, but not optimized for prefix search
- CompressedRadixTrie: O(k), but high implementation and maintenance complexity for the team and context

###  2.2 Layered Architecture

<p align="center">
  <img src="https://github.com/mperugini/SampleCities/blob/private/mperugini/docs/docs/assets/arq1.png?raw=true" width="600" />
</p>


### 2.3 Key Components

#### 2.3.1 Search Engine (CitySearchIndex)
```swift
actor CitySearchIndex {
    func search(prefix: String, maxResults: Int = 50) -> [City] // Adaptive O(n) or O(log n)
    func buildIndex(from cities: [City]) async // O(n log n) one-time
    // Hybrid approach: linear search for short prefixes, binary for long ones
}
```

#### 2.3.2 Weather Integration
```swift
protocol WeatherService {
    func getWeather(for city: City) async throws -> WeatherInfo
    func cacheWeather(_ weather: WeatherInfo, for city: City)
}
```

---

## 3. Implementation Strategy

### 3.1 Technology Stack

<table>
 <thead>
   <tr>
     <th>Component</th>
     <th>Technology</th>
     <th>Rationale</th>
   </tr>
 </thead>
 <tbody>
   <tr>
     <td><strong>Language</strong></td>
     <td>Swift 6.0</td>
     <td>Latest features, performance, type safety</td>
   </tr>
   <tr>
     <td><strong>UI Framework</strong></td>
     <td>SwiftUI</td>
     <td>Declarative, responsive, modern</td>
   </tr>
   <tr>
     <td><strong>Persistence</strong></td>
     <td>Core Data</td>
     <td>Native, optimized, ACID compliance</td>
   </tr>
   <tr>
     <td><strong>Networking</strong></td>
     <td>URLSession + async/await</td>
     <td>Native, modern, no external dependencies</td>
   </tr>
   <tr>
     <td><strong>Maps</strong></td>
     <td>MapKit</td>
     <td>Native, optimized, no extra cost</td>
   </tr>
   <tr>
     <td><strong>Testing</strong></td>
     <td>XCTest</td>
     <td>Native, integrated, complete</td>
   </tr>
 </tbody>
</table>

### 3.2 External Dependencies
- **OpenWeather API:** Real-time weather data
- **Core Data:** Local persistence (iOS native)
- **MapKit:** Interactive maps (iOS native)


### 3.3 Effort Estimation

<table>
 <thead>
   <tr>
     <th>Sprint</th>
     <th>Duration</th>
     <th>Focus</th>
   </tr>
 </thead>
 <tbody>
   <tr>
     <td><strong>Sprint 1</strong></td>
     <td>2 weeks</td>
     <td>Architecture + Search Engine</td>
   </tr>
   <tr>
     <td><strong>Sprint 2</strong></td>
     <td>2 weeks</td>
     <td>UI + Maps + Weather + Performance Tunning</td>
   </tr>
   <tr>
     <td><strong>Sprint 3</strong></td>
     <td>2 weeks</td>
     <td>Favorites + Testing + Polish</td>
   </tr>
   <tr>
     <td><strong>Total</strong></td>
     <td>6 weeks</td>
     <td></td>
   </tr>
 </tbody>
</table>


---

## 4. Team Organization & Work Distribution

### 4.1 Team Structure

#### 4.1.1 Roles & Responsibilities

| Role | Key Responsibilities |
|------|---------------------|
| **Tech Lead** | • Architecture and technical decisions<br>• Code reviews and mentoring<br>• Performance optimization<br>• Stakeholder communication |
| **Senior iOS Developer (1)** | • Domain layer implementation<br>• Search engine optimization<br>• Core Data setup<br>• Unit testing |
| **Mid iOS Developer (1)** | • Data layer implementation<br>• Network services<br>• Weather integration<br>• Integration testing |
| **Junior iOS Developer (1)** | • Presentation layer (Views)<br>• UI components<br>• Basic ViewModels<br>• UI testing |
| **QA Engineer (1)** | • Test planning<br>• Manual testing<br>• Performance testing<br>• User acceptance testing |

### 4.2 Work Distribution by Sprint

#### Sprint 1: Foundation + Search Engine
```
Tech Lead:     Architecture setup, dependency injection, SearchIndex 
Senior Dev:    Domain models, repository protocols, search use cases 
Mid Dev:       Core Data stack, basic networking, performance testing 
```

#### Sprint 2: UI + Maps + Weather 
```
Tech Lead:     MapKit integration, weather service architecture 
Senior Dev:    Search UI, results list, weather overlay 
Mid Dev:       City cards, navigation, cache implementation
```

#### Sprint 3: Favorites + Testing + Polish 
```
Tech Lead:     Performance optimization, final architecture review, feature flag Remote config 
Senior Dev:    Favorites use cases, Core Data models, unit testing
Mid Dev:       Favorites UI, integration testing, UI testing 
```

### 4.3 Code Quality Guardrails

#### 4.3.1 Development Process
1. **Feature Branch:** Each feature in a separate branch
2. **Code Review:** Mandatory, minimum 2 approvals
3. **Automated Testing:** CI/CD pipeline with automated tests (Github Actions/ Xcode Cloud)
4. **Performance Gates:** Performance metrics in every PR

#### 4.3.2 Coding Standards
- **SwiftLint:** Strict rules configured
- **Documentation:** 100% of public APIs documented
- **Test Coverage:** Minimum 80% for new features
- **Performance:** Search < 100ms, UI < 16ms

---



