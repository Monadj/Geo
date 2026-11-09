import SwiftUI
import MapKit

// MARK: - App Entry Point & Tab View Controller
struct MainViewController: View {
    @StateObject private var manager = CampusDataManager()
    
    var body: some View {
        TabView(selection: $manager.selectedTab) {
            // Màn 1: Full Map & Search
            MapView(manager: manager)
                .tabItem {
                    Label("Bản đồ", systemImage: "map")
                }
                .tag(0)
            
            // Màn 2: Places List
            PlacesListView(manager: manager)
                .tabItem {
                    Label("Địa điểm", systemImage: "list.bullet")
                }
                .tag(1)
            
            // Màn 3: My Visit
            MyVisitView(manager: manager)
                .tabItem {
                    Label("My Visit", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .accentColor(.primary)
    }
}

// MARK: - Màn hình 1: Map View với cơ chế Zoom động theo State
struct MapView: View {
    @ObservedObject var manager: CampusDataManager
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    
    private let campusCenter = CLLocationCoordinate2D(latitude: 10.8750, longitude: 106.8010)
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.8750, longitude: 106.8010),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    var filteredPlaces: [CampusPlace] {
        if searchText.isEmpty {
            return manager.places
        }
        return manager.places.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $position) {
                    UserAnnotation()
                    
                    ForEach(filteredPlaces) { place in
                        Annotation(place.name, coordinate: place.coordinate) {
                            NavigationLink(destination: PlaceDetailView(place: place, manager: manager)) {
                                VStack(spacing: 2) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(manager.selectedPlaceID == place.id ? .blue : .red)
                                        .background(Circle().fill(Color.white))
                                        .shadow(radius: 2)
                                    
                                    Text(place.code)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(4)
                                        .shadow(radius: 1)
                                }
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                // Ô tìm kiếm Overlay
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Tìm trường, KTX, điểm đến...", text: $searchText)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground).opacity(0.95))
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                // Nút định vị GPS / Reset góc nhìn
                Button(action: {
                    if let userCoords = locationManager.userLocation {
                        withAnimation {
                            position = .region(MKCoordinateRegion(center: userCoords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                        }
                    } else {
                        locationManager.requestPermission()
                        withAnimation {
                            position = .region(MKCoordinateRegion(center: campusCenter, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)))
                        }
                    }
                }) {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding(14)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Làng Đại học ĐHQG")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestPermission()
            }
            // Lắng nghe sự thay đổi của selectedPlaceID để tự động Zoom camera tới địa điểm đó
            .onChange(of: manager.selectedPlaceID) { newID in
                if let id = newID, let targetPlace = manager.places.first(where: { $0.id == id }) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        position = .region(
                            MKCoordinateRegion(
                                center: targetPlace.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                            )
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Màn hình 2: Places List
struct PlacesListView: View {
    @ObservedObject var manager: CampusDataManager
    @State private var searchText = ""
    
    var filteredPlaces: [CampusPlace] {
        if searchText.isEmpty {
            return manager.places
        }
        return manager.places.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredPlaces) { place in
                NavigationLink(destination: PlaceDetailView(place: place, manager: manager)) {
                    PlaceRowView(
                        place: place,
                        isFavorite: manager.favoriteIDs.contains(place.id),
                        isVisited: manager.visitedIDs.contains(place.id),
                        onToggleFavorite: { manager.toggleFavorite(place) }
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Tìm địa điểm...")
            .navigationTitle("Địa điểm Campus")
        }
    }
}

// MARK: - Màn hình 3: My Visit
struct MyVisitView: View {
    @ObservedObject var manager: CampusDataManager
    
    var visitedPlaces: [CampusPlace] {
        manager.places.filter { manager.visitedIDs.contains($0.id) }
    }
    
    var favoritePlaces: [CampusPlace] {
        manager.places.filter { manager.favoriteIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Đã đến (\(visitedPlaces.count))")) {
                    if visitedPlaces.isEmpty {
                        Text("Chưa check-in địa điểm nào")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(visitedPlaces) { place in
                            NavigationLink(destination: PlaceDetailView(place: place, manager: manager)) {
                                PlaceRowView(
                                    place: place,
                                    isFavorite: manager.favoriteIDs.contains(place.id),
                                    isVisited: true,
                                    onToggleFavorite: { manager.toggleFavorite(place) }
                                )
                            }
                        }
                    }
                }
                
                Section(header: Text("Danh sách yêu thích (\(favoritePlaces.count))")) {
                    if favoritePlaces.isEmpty {
                        Text("Chưa có địa điểm yêu thích")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(favoritePlaces) { place in
                            NavigationLink(destination: PlaceDetailView(place: place, manager: manager)) {
                                PlaceRowView(
                                    place: place,
                                    isFavorite: true,
                                    isVisited: manager.visitedIDs.contains(place.id),
                                    onToggleFavorite: { manager.toggleFavorite(place) }
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Visit")
        }
    }
}