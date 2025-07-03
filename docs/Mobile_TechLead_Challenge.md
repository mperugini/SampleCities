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


