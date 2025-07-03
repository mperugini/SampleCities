//  SmartCityExploration
//
//  Created by Mariano Perugini on 1/07/25.
//

import SwiftUI
import MapKit

@MainActor
struct SmartCitySearchView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var selectedCity: City?
    @State private var navigationPath = NavigationPath()
    @State private var lastPortraitCity: City?
    
    let viewModel: CitySearchViewModel
    
    init(viewModel: CitySearchViewModel) {
        self.viewModel = viewModel
    }
    
    private var isLandscape: Bool {
        // En iPhone, landscape es cuando horizontalSizeClass es .regular
        // En iPad, siempre es .regular, así que uso verticalSizeClass para detectar landscape
        if UIDevice.current.userInterfaceIdiom == .phone {
            return horizontalSizeClass == .regular
        } else {
            return verticalSizeClass == .compact
        }
    }
    
    var body: some View {
        Group {
            if isLandscape {
                // Landscape
                NavigationSplitView {
                    searchList
                } detail: {
                    if let city = selectedCity {
                        CityMapView(city: city)
                    } else {
                        ContentUnavailableView(
                            "Select a City",
                            systemImage: "map",
                            description: Text("Choose a city to see it on the map")
                        )
                    }
                }
            } else {
                // Portrait
                NavigationStack(path: $navigationPath) {
                    searchList
                        .navigationDestination(for: City.self) { city in
                            CityDetailView(city: city)
                        }
                }
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onChange(of: isLandscape) { _, newIsLandscape in
            if newIsLandscape {
                // Si cambiamos de portrait a landscape y hay una ciudad en portrait
                // la seleccionamos para el split view
                if let city = lastPortraitCity {
                    selectedCity = city
                }
            } else {
                // Si cambiamos de landscape a portrait y hay una ciudad seleccionada,
                // la guardamos como ultima ciudad en portrait
                if let city = selectedCity {
                    lastPortraitCity = city
                    // Limpiar el path y agregar solo la ciudad actual
                    navigationPath = NavigationPath([city])
                }
            }
        }
    }
    
    private var searchList: some View {
        List {
            if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                Text("No cities found")
                    .foregroundStyle(.secondary)
            } else if viewModel.searchResults.isEmpty && viewModel.searchText.isEmpty {
                Text("Search for cities to get started")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.searchResults, id: \.id) { city in
                    CityRowView(
                        city: city, 
                        isFavorite: viewModel.isFavorite(city),
                        onToggleFavorite: {
                            Task {
                                await viewModel.toggleFavorite(city)
                            }
                        }
                    )
                    .onTapGesture {
                        if isLandscape {
                            selectedCity = city
                            viewModel.selectCity(city)
                        } else {
                            // En portrait, navegar a la pantalla de detalle
                            lastPortraitCity = city
                            // Limpiar el path y agregar solo la nueva ciudad
                            navigationPath = NavigationPath([city])
                        }
                    }
                }
                
            }
        }
        .navigationTitle("Cities")
        .searchable(
            text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.searchText = $0 }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search cities"
        )
        .submitLabel(.done)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .onSubmit {
            // Dismiss keyboard when Done is pressed
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Refresh") {
                    Task {
                        await viewModel.refreshCities()
                    }
                }
                .disabled(viewModel.isLoading)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    viewModel.close()
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading cities")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
            }
        }
    }
}

// MARK: - City Map View
struct CityMapView: View {
    let city: City
    @State private var position: MapCameraPosition
    @State private var weatherInfo: WeatherInfo?
    @State private var isLoadingWeather = false
    @State private var weatherError: Error?
    @State private var lastLoadedCityId: Int?
    @State private var weatherCache: [Int: WeatherInfo] = [:]
    
    private let weatherService = WeatherService()
    
    private var annotation: CityAnnotation {
        CityAnnotation(city: city)
    }
    
    init(city: City) {
        self.city = city
        self._position = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: city.coord.lat,
                longitude: city.coord.lon
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1
            )
        )))
    }
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                Marker(city.name, coordinate: annotation.coordinate)
                    .tint(.red)
            }
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: city.id) { _, newId in
                if lastLoadedCityId != newId {
                    lastLoadedCityId = newId
                    withAnimation {
                        position = .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: city.coord.lat,
                                longitude: city.coord.lon
                            ),
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.1,
                                longitudeDelta: 0.1
                            )
                        ))
                    }

                    Task {
                        await loadWeather()
                    }
                }
            }
            
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

// MARK: - City Row View
struct CityRowView: View {
    let city: City
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            }
        }
        .padding(.vertical, 4)
    }
}
