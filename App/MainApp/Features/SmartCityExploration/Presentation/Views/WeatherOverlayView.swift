//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import SwiftUI

struct WeatherOverlayView: View {
    let weatherInfo: WeatherInfo?
    let isLoading: Bool
    let error: Error?
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                if isLoading {
                    WeatherLoadingView()
                } else if let error = error {
                    WeatherErrorView(error: error)
                } else if let weatherInfo = weatherInfo {
                    WeatherInfoView(weatherInfo: weatherInfo)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 100) 
        }
    }
}

struct WeatherInfoView: View {
    let weatherInfo: WeatherInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: weatherIconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "cloud")
                        .foregroundColor(.gray)
                }
                .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(round(weatherInfo.temperature)))°C")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(weatherInfo.description.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "thermometer")
                        .foregroundColor(.orange)
                    Text("Sensación: \(Int(round(weatherInfo.feelsLike)))°C")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "humidity")
                        .foregroundColor(.blue)
                    Text("Humedad: \(weatherInfo.humidity)%")
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    private var weatherIconURL: URL? {
        URL(string: "https://openweathermap.org/img/wn/\(weatherInfo.icon)@2x.png")
    }
}

struct WeatherLoadingView: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Cargando clima...")
                .font(.caption)
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct WeatherErrorView: View {
    let error: Error
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            Text("Request error")
                .font(.caption)
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
} 
