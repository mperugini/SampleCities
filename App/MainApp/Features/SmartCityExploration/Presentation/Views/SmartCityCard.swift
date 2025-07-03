//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import SwiftUI

struct SmartCityCard: View, Sendable {
    let onExploreTapped: () -> Void
    let statsService: any StatsService
    
    @State private var totalCities: Int = 0
    @State private var favoriteCities: Int = 0
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
              
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Discover cities around the world")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                StatItem(
                    icon: "building.2",
                    value: "\(totalCities)",
                    label: "Cities"
                )
                
                StatItem(
                    icon: "heart.fill",
                    value: "\(favoriteCities)",
                    label: "Favorites"
                )
                
                Spacer()
            }
            
            // Action Button
            Button(action: onExploreTapped) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Smart City Explorer")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        isLoading = true
        
        Task {
            // print("[SmartCityCard] Loading real stats from Core Data...")
            
            async let totalCitiesTask = statsService.getTotalCities()
            async let favoriteCitiesTask = statsService.getFavoriteCitiesCount()
            
            let (totalResult, favoritesResult) = await (totalCitiesTask, favoriteCitiesTask)
            let total: Int
            let favorites: Int
            
            switch totalResult {
            case .success(let value):
                total = value
            case .failure:
                total = 0
            }
            
            switch favoritesResult {
            case .success(let value):
                favorites = value
            case .failure:
                favorites = 0
            }
            
            await MainActor.run {
                self.totalCities = total
                self.favoriteCities = favorites
                self.isLoading = false
                // print("[SmartCityCard] Stats loaded: \(total) cities, \(favorites) favorites")
            }
        }
    }
}

// MARK: - Stat Item Component
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
