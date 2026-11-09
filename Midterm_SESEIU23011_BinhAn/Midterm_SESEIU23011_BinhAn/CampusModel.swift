//
//  CampusPlace.swift
//  Midterm_SESEIU23011_BinhAn
//
//  Created by MAY 01 on 9/11/26.
//


import Foundation
import CoreLocation
import Combine

// MARK: - 1. Domain Model (Ứng dụng OOP: Encapsulation, Properties, Custom Init & Methods)
struct CampusPlace: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let code: String
    let category: String
    let latitude: Double
    let longitude: Double
    let hours: String
    let description: String
    
    // Computed Property trả về tọa độ chuẩn MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Custom Initializer (Khởi tạo đối tượng từ các thành phần nguyên thủy)
    init(id: String, name: String, code: String, category: String, latitude: Double, longitude: Double, hours: String, description: String) {
        self.id = id
        self.name = name
        self.code = code
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.hours = hours
        self.description = description
    }
    
    // Domain Method: Khởi tạo từ chuỗi dòng text phân tách (Parse Rule)
    init?(fromRawLine line: String) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed.hasPrefix("#") { return nil }
        
        let parts = trimmed.components(separatedBy: "|")
        guard parts.count >= 7 else { return nil }
        
        self.id = parts[0].trimmingCharacters(in: .whitespaces)
        self.name = parts[1].trimmingCharacters(in: .whitespaces)
        self.code = parts[2].trimmingCharacters(in: .whitespaces)
        self.category = parts[3].trimmingCharacters(in: .whitespaces)
        self.latitude = Double(parts[4].trimmingCharacters(in: .whitespaces)) ?? 0.0
        self.longitude = Double(parts[5].trimmingCharacters(in: .whitespaces)) ?? 0.0
        self.hours = parts[6].trimmingCharacters(in: .whitespaces)
        self.description = parts.count > 7 ? parts[7].trimmingCharacters(in: .whitespaces) : ""
    }
    
    // Meaningful Domain Method: Kiểm tra khoảng cách từ vị trí người dùng đến địa điểm này
    func distance(from userLocation: CLLocationCoordinate2D?) -> CLLocationDistance? {
        guard let userLoc = userLocation else { return nil }
        let placeCoord = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let userCoord = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        return placeCoord.distance(from: userCoord)
    }
    
    // Meaningful Domain Method: Format hiển thị tọa độ gọn gàng
    func formattedCoordinates() -> String {
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
}

// MARK: - 2. Location Manager (GPS State Engine)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
}

// MARK: - 3. State Management & Controller Layer (Điều phối ứng dụng & Refresh SwiftUI)
class CampusDataManager: ObservableObject {
    @Published var places: [CampusPlace] = []
    @Published var favoriteIDs: Set<String> = [] {
        didSet { saveFavorites() }
    }
    @Published var visitedIDs: Set<String> = [] {
        didSet { saveVisited() }
    }
    
    // Quản lý trạng thái Navigation và Zoom Map giữa các tab
    @Published var selectedPlaceID: String? = nil {
        didSet {
            if selectedPlaceID != nil {
                selectedTab = 0 // Tự động chuyển về Tab Bản đồ (Tag 0) khi chọn điểm
            }
        }
    }
    @Published var selectedTab: Int = 0 
    
    private let favoritesKey = "CampusFavoriteIDs"
    private let visitedKey = "CampusVisitedIDs"
    
    init() {
        loadDataFromTextFile()
        loadSavedState()
    }
    
    // Đọc và phân tích dữ liệu từ file text local
    private func loadDataFromTextFile() {
        guard let fileURL = Bundle.main.url(forResource: "campus_data", withExtension: "txt") else {
            self.places = parseRawText(rawDefaultData)
            return
        }
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            self.places = parseRawText(content)
        } catch {
            print("Lỗi đọc file text: \(error)")
            self.places = parseRawText(rawDefaultData)
        }
    }
    
    private func parseRawText(_ text: String) -> [CampusPlace] {
        var result: [CampusPlace] = []
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            if let place = CampusPlace(fromRawLine: line) {
                result.append(place)
            }
        }
        return result
    }
    
    // Business Logic: Quản lý Yêu thích & Check-in
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
    
    // Application Coordination: Yêu cầu xem điểm trên bản đồ và zoom tới
    func navigateToMap(for place: CampusPlace) {
        selectedPlaceID = place.id
        selectedTab = 0 // Chuyển sang Tab Map
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

// Dữ liệu dự phòng mặc định
private let rawDefaultData = """
# ID|Name|Code|Category|Latitude|Longitude|Hours|Description
UIT|Đại học Công nghệ Thông tin|UIT|Trường Đại Học|10.870020|106.803060|07:00 - 17:30|Trường thành viên chuyên đào tạo CNTT & Truyền thông thuộc ĐHQG-HCM.
USSH|Đại học Khoa học Xã hội & Nhân văn|USSH|Trường Đại Học|10.872150|106.802100|07:30 - 17:00|Cơ sở Thủ Đức chuyên đào tạo các khối ngành khoa học xã hội và nhân văn.
KTXA|KTX Khu A ĐHQG-HCM|KTX-A|Ký Túc Xá|10.878200|106.806300|05:00 - 23:00|Khu ký túc xá sinh viên lớn tập trung nhiều dịch vụ tiện ích.
"""