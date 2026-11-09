import Foundation
import CoreLocation
import Combine // Import để hỗ trợ ObservableObject và @Published

// MARK: - Data Models
struct CampusPlace: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let code: String
    let category: String
    let latitude: Double
    let longitude: Double
    let description: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Data Manager (Controller/Store Engine)
class CampusDataManager: ObservableObject {
    @Published var places: [CampusPlace] = []
    @Published var favoriteIDs: Set<String> = [] {
        didSet { saveFavorites() }
    }
    @Published var visitedIDs: Set<String> = [] {
        didSet { saveVisited() }
    }
    
    private let favoritesKey = "CampusFavoriteIDs"
    private let visitedKey = "CampusVisitedIDs"
    
    init() {
        loadDataFromTextFile()
        loadSavedState()
    }
    
    // Đọc dữ liệu từ file text "campus_data.txt" (Phân tách bằng gạch đứng |)
    private func loadDataFromTextFile() {
        _ = Bundle.main.url(forResource: "Campus_data", withExtension: "txt")
    }
    
    private func parseRawText(_ text: String) -> [CampusPlace] {
        var result: [CampusPlace] = []
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            let parts = trimmed.components(separatedBy: "|")
            if parts.count >= 6 {
                let place = CampusPlace(
                    id: parts[0].trimmingCharacters(in: .whitespaces),
                    name: parts[1].trimmingCharacters(in: .whitespaces),
                    code: parts[2].trimmingCharacters(in: .whitespaces),
                    category: parts[3].trimmingCharacters(in: .whitespaces),
                    latitude: Double(parts[4].trimmingCharacters(in: .whitespaces)) ?? 0.0,
                    longitude: Double(parts[5].trimmingCharacters(in: .whitespaces)) ?? 0.0,
                    description: parts.count > 6 ? parts[6].trimmingCharacters(in: .whitespaces) : ""
                )
                result.append(place)
            }
        }
        return result
    }
    
    // Toggle trạng thái Yêu thích / Đã đến
    func toggleFavorite(_ place: CampusPlace) {
        if favoriteIDs.contains(place.id) {
            favoriteIDs.remove(place.id)
        } else {
            favoriteIDs.insert(place.id)
        }
    }
    
    func toggleVisited(_ place: CampusPlace) {
        if visitedIDs.contains(place.id) {
            visitedIDs.remove(place.id)
        } else {
            visitedIDs.insert(place.id)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }
    
    private func saveVisited() {
        UserDefaults.standard.set(Array(visitedIDs), forKey: visitedKey)
    }
    
    private func loadSavedState() {
        if let favs = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteIDs = Set(favs)
        }
        if let visited = UserDefaults.standard.array(forKey: visitedKey) as? [String] {
            visitedIDs = Set(visited)
        }
    }
}


