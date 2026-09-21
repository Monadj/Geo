import SwiftUI
import MapKit

// MARK: - Model (Struct)
struct CustomButtonItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var iconName: String
    var xValue: Double // Kinh độ (Longitude)
    var yValue: Double // Vĩ độ (Latitude)
    
    // Tự động quy đổi X, Y sang Tọa độ GPS (Tự động lấy vị trí mặc định nếu X, Y = 0)
    var coordinate: CLLocationCoordinate2D {
        let lat = (yValue >= -90 && yValue <= 90 && yValue != 0) ? yValue : 10.7769 // Vĩ độ mặc định (TP.HCM)
        let lon = (xValue >= -180 && xValue <= 180 && xValue != 0) ? xValue : 106.7009 // Kinh độ mặc định
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - Main Screen
struct ContentView: View {
    @State private var selectedItem: CustomButtonItem? = nil
    @State private var buttonList: [CustomButtonItem] = [
        CustomButtonItem(
            title: "Đại học Quốc tế",
            iconName: "building.columns.fill",
            xValue: 106.8016,
            yValue: 10.8775
        ),
        CustomButtonItem(
            title: "KTX Khu A ĐHQG",
            iconName: "house.lodge.fill",
            xValue: 106.8073,
            yValue: 10.8775
        ),
        CustomButtonItem(
            title: "Bcons Suối Tiên",
            iconName: "building.2.fill",
            xValue: 106.8090,
            yValue: 10.8759
        )
    ]
    var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    if buttonList.isEmpty {
                        // Empty State
                        VStack(spacing: 12) {
                            Image(systemName: "square.dashed")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Chưa có nút nào")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("Bấm 'Thêm Nút Mới' phía dưới để bắt đầu tạo.")
                                .font(.system(size: 13))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 24)
                    } else {
                        // List View
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(buttonList) { item in
                                    SwipeableCardView(
                                        item: item,
                                        onTap: { selectedItem = item },
                                        onDelete: { deleteItem(item) }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        }
                    }

                    // Add Button
                    NavigationLink(destination: AddButtonView { newItem in
                        buttonList.append(newItem)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Thêm Nút Mới")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.primary)
                        .cornerRadius(18)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
                .navigationTitle("My Buttons")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if !buttonList.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(destination: AllButtonsMapView(buttons: buttonList)) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                    }
                }
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                .navigationDestination(item: $selectedItem) { item in
                    ButtonMapView(item: item)
                }
            }
        }
        
        private func deleteItem(_ item: CustomButtonItem) {
            withAnimation(.spring()) {
                buttonList.removeAll { $0.id == item.id }
            }
        }
    }

    // MARK: - Single Item Map View
    struct ButtonMapView: View {
        let item: CustomButtonItem
        @State private var position: MapCameraPosition
        
        init(item: CustomButtonItem) {
            self.item = item
            _position = State(initialValue: .region(
                MKCoordinateRegion(
                    center: item.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                )
            ))
        }
        
        var body: some View {
            ZStack(alignment: .bottom) {
                Map(position: $position) {
                    // anchor: .bottom aligns pointer tip precisely to coordinate
                    Annotation(item.title, coordinate: item.coordinate, anchor: .bottom) {
                        VStack(spacing: 0) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                            
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.accentColor)
                                .rotationEffect(.degrees(180))
                                .offset(y: -3)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Info Card Bottom Sheet
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: item.iconName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                        
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("KINH ĐỘ (X)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.4f", item.xValue))")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("VĨ ĐỘ (Y)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.4f", item.yValue))")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .padding(20)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Vị Trí Bản Đồ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - All Items Map View
    struct AllButtonsMapView: View {
        let buttons: [CustomButtonItem]
        
        var body: some View {
            Map {
                ForEach(buttons) { item in
                    Annotation(item.title, coordinate: item.coordinate, anchor: .bottom) {
                        VStack(spacing: 0) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.primary)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                            
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.primary)
                                .rotationEffect(.degrees(180))
                                .offset(y: -2)
                        }
                    }
                }
            }
            .navigationTitle("Tất Cả Vị Trí")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Swipeable Card Component
    struct SwipeableCardView: View {
        let item: CustomButtonItem
        let onTap: () -> Void
        let onDelete: () -> Void
        
        @State private var offset: CGFloat = 0
        @State private var isSwiped: Bool = false
        
        var body: some View {
            ZStack(alignment: .trailing) {
                // Delete Action Background
                HStack(spacing: 0) {
                    Spacer()
                    if offset < 0 {
                        Button(action: onDelete) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(min(1.1, max(0.5, -offset / 70)))
                                .frame(width: max(0, -offset))
                                .frame(maxHeight: .infinity)
                                .background(Color.red)
                                .cornerRadius(20)
                        }
                    }
                }
                
                // Main Card Foreground
                HStack(spacing: 16) {
                    Image(systemName: item.iconName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 56, height: 56)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("X: \(String(format: "%.4f", item.xValue))  •  Y: \(String(format: "%.4f", item.yValue))")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Image(systemName: "map")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                .padding(16)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                .offset(x: offset)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if isSwiped {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                isSwiped = false
                            }
                        } else {
                            onTap()
                        }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 15)
                        .onChanged { gesture in
                            if gesture.translation.width < 0 {
                                offset = isSwiped ? gesture.translation.width - 85 : gesture.translation.width
                            } else if isSwiped && gesture.translation.width > 0 {
                                offset = gesture.translation.width - 85
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.68)) {
                                if offset < -140 {
                                    onDelete()
                                } else if offset < -45 {
                                    offset = -85
                                    isSwiped = true
                                } else {
                                    offset = 0
                                    isSwiped = false
                                }
                            }
                        }
                )
            }
        }
    }

    // MARK: - Add Button Screen
    struct AddButtonView: View {
        @Environment(\.dismiss) private var dismiss
        
        @State private var title: String = ""
        @State private var selectedIcon: String = "bolt.fill"
        @State private var xInput: String = ""
        @State private var yInput: String = ""

        var onSave: (CustomButtonItem) -> Void

        let sampleIcons = [
            "building.columns.fill", "house.lodge.fill", "building.2.fill", "map.fill",
            "star.fill", "bolt.fill", "flame.fill", "target", "bookmark.fill", "bell.fill"
        ]

        var body: some View {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TÊN NÚT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            TextField("Vd: Action Button", text: $title)
                                .font(.system(size: 16, weight: .regular))
                                .padding(16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("CHỌN BIỂU TƯỢNG (ICON)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                                ForEach(sampleIcons, id: \.self) { icon in
                                    Image(systemName: icon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(selectedIcon == icon ? .white : .primary)
                                        .frame(height: 52)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedIcon == icon ? Color.primary : Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .onTapGesture {
                                            selectedIcon = icon
                                        }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("TỌA ĐỘ GPS (X: KINH ĐỘ, Y: VĨ ĐỘ)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 16) {
                                HStack {
                                    Text("X:")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16, weight: .semibold))
                                    TextField("106.8016", text: $xInput)
                                        .keyboardType(.decimalPad)
                                }
                                .padding(16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                
                                HStack {
                                    Text("Y:")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16, weight: .semibold))
                                    TextField("10.8775", text: $yInput)
                                        .keyboardType(.decimalPad)
                                }
                                .padding(16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }

                Button(action: {
                    let cleanX = xInput.replacingOccurrences(of: ",", with: ".")
                    let cleanY = yInput.replacingOccurrences(of: ",", with: ".")
                    let xVal = Double(cleanX) ?? 0.0
                    let yVal = Double(cleanY) ?? 0.0
                    let cleanTitle = title.trimmingCharacters(in: .whitespaces).isEmpty ? "Nút Chưa Tên" : title
                    
                    let newItem = CustomButtonItem(title: cleanTitle, iconName: selectedIcon, xValue: xVal, yValue: yVal)
                    onSave(newItem)
                    dismiss()
                }) {
                    Text("Lưu Nút")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.primary)
                        .cornerRadius(18)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle("Tạo Nút Mới")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }

    #Preview {
        ContentView()
    }
