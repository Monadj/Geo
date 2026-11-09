import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                // Nếu đã có tọa độ, hiển thị bản đồ và ghim Marker ngay lập tức
                if let lat = locationManager.latitude, let lng = locationManager.longitude {
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    
                    Map(initialPosition: .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )) {
                        Marker("Vị trí của tôi", coordinate: coordinate)
                            .tint(.blue)
                    }
                    .frame(height: 350)
                    .cornerRadius(12)
                } else {
                    // Màn hình chờ khi chưa có tọa độ GPS hoặc chưa chọn Location trong Simulator
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 350)
                        .overlay(
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Đang chờ tín hiệu GPS...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        )
                }

                // Hiển thị thông số Vĩ độ & Kinh độ
                Group {
                    if let lat = locationManager.latitude, let lng = locationManager.longitude {
                        statusRow(title: "Latitude (Vĩ độ)", value: String(format: "%.6f", lat))
                        statusRow(title: "Longitude (Kinh độ)", value: String(format: "%.6f", lng))
                    } else {
                        statusRow(title: "Tọa độ", value: "Chưa có dữ liệu")
                    }
                }

                Spacer()

                Button("Refresh Status") {
                    locationManager.refreshStatus()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Live Map")
            .onAppear {
                locationManager.refreshStatus()
            }
        }
    }

    @ViewBuilder
    private func statusRow(title: String, value: String) -> some View {
        HStack {
            Text(title + ":")
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
