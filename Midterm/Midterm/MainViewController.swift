import SwiftUI
import MapKit

// MARK: - App Entry Point & Tab View Controller
struct MainViewController: View {
    @StateObject private var manager = CampusDataManager()
    
    var body: some View {
        TabView {
            // Màn 1: Full Map & Tìm kiếm
            MapView(manager: manager)
                .tabItem {
                    Label("Bản đồ", systemImage: "map")
                }
            
            // Màn 2: Danh sách Places
            PlacesListView(manager: manager)
                .tabItem {
                    Label("Địa điểm", systemImage: "list.bullet")
                }
            
            // Màn 3: My Visit (Đã đến & Yêu thích)
            MyVisitView(manager: manager)
                .tabItem {
                    Label("My Visit", systemImage: "person.crop.circle")
                }
        }
        .accentColor(.primary)
    }
}

// MARK: - Màn hình 1: Full Map & Search
struct MapView: View {
    @ObservedObject var manager: CampusDataManager
    @State private var searchText = ""
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.8750, longitude: 106.8010),
            span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
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
            ZStack(alignment: .top) {
                Map(position: $position) {
                    ForEach(filteredPlaces) { place in
                        Annotation(place.code, coordinate: place.coordinate) {
                            NavigationLink(destination: PlaceDetailView(place: place, manager: manager)) {
                                VStack(spacing: 2) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.primary)
                                        .background(Circle().fill(Color(.systemBackground)))
                                    Text(place.name)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemBackground).opacity(0.9))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                // Bộ tìm kiếm overlay trên Map
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Tìm trường, KTX, điểm đến...", text: $searchText)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Làng Đại học ĐHQG")
            .navigationBarTitleDisplayMode(.inline)
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
