//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import SwiftUI

struct MainHomeView: View {
    let statsService: any StatsService
    let onSmartCityExplorationTapped: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    
                    Text("Discover and explore cities from around the world")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                SmartCityCard(
                    onExploreTapped: onSmartCityExplorationTapped,
                    statsService: statsService
                )
                .padding(.horizontal, 20)
                
                VStack(spacing: 16) {
                    FeatureCard(
                        icon: "map.fill",
                        title: "Interactive Maps",
                        description: "Explore cities with detailed maps and locations",
                        color: .green
                    )
                    
                    FeatureCard(
                        icon: "heart.fill",
                        title: "Favorites",
                        description: "Save your favorite cities for quick access",
                        color: .red
                    )
                    
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Feature Card Component
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
