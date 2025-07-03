//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import SwiftUI
import MapKit

struct CityDetailView: View {
    let city: City
    @State private var cameraPosition: MapCameraPosition
    @State private var weatherInfo: WeatherInfo?
    @State private var isLoadingWeather = false
    @State private var weatherError: Error?
    @State private var lastLoadedCityId: Int?
    @State private var weatherCache: [Int: WeatherInfo] = [:]
    
    private let weatherService = WeatherService()
    
    init(city: City) {
        self.city = city
        
        // Debug log to verify coordinates
        // print("[CityDetailView] Initializing with city: \(city.name)")
        // print("[CityDetailView] Coordinates: lat=\(city.coord.lat), lon=\(city.coord.lon)")
        
        self._cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: city.coord.lat,
                longitude: city.coord.lon
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                Annotation(city.name, coordinate: CLLocationCoordinate2D(
                    latitude: city.coord.lat,
                    longitude: city.coord.lon
                )) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        
                        Text(city.name)
                            .font(.caption)
                            .padding(4)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
            
            // Weather overlay en la esquina inferior derecha
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    WeatherOverlayView(
                        weatherInfo: weatherInfo,
                        isLoading: isLoadingWeather,
                        error: weatherError
                    )
                    .frame(width: 240, height: 80)
                    .padding()
                }
            }
        }
        .task {
            if lastLoadedCityId != city.id {
                lastLoadedCityId = city.id
                await loadWeather()
            }
        }
    }
    
    private func loadWeather() async {
        isLoadingWeather = true
        weatherError = nil
        
        // Usar cache si existe
        if let cached = weatherCache[city.id] {
            await MainActor.run {
                weatherInfo = cached
                isLoadingWeather = false
            }
            return
        }
        
        let result = await weatherService.getWeather(for: city)
        
        await MainActor.run {
            isLoadingWeather = false
            
            switch result {
            case .success(let weather):
                weatherInfo = weather
                weatherCache[city.id] = weather
            case .failure(let error):
                weatherError = error
            }
        }
    }
}
