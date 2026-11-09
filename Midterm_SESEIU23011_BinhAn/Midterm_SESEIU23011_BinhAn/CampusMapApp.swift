import SwiftUI

@main
struct CampusMapApp: App { // Tên struct này sẽ tùy thuộc vào tên lúc bạn tạo project
    var body: some Scene {
        WindowGroup {
            MainViewController() // <-- Gọi màn hình TabView chứa toàn bộ app ở đây
        }
    }
}