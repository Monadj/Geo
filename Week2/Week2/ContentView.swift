import SwiftUI

// MARK: - Model
struct CustomButtonItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var iconName: String
    var xValue: Double
    var yValue: Double
}

// MARK: - Main Screen
struct ContentView: View {
    @State private var buttonList: [CustomButtonItem] = []
    @State private var selectedItem: CustomButtonItem? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if buttonList.isEmpty {
                    // Trạng thái trống
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
                    // Danh sách Card
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

                // MARK: - Nút Thêm bự ở cuối
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
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .alert(item: $selectedItem) { item in
                Alert(
                    title: Text(item.title),
                    message: Text("Tọa độ X: \(String(format: "%.2f", item.xValue))\nTọa độ Y: \(String(format: "%.2f", item.yValue))"),
                    dismissButton: .default(Text("Đóng"))
                )
            }
        }
    }
    
    private func deleteItem(_ item: CustomButtonItem) {
        withAnimation(.spring()) {
            buttonList.removeAll { $0.id == item.id }
        }
    }
}

// MARK: - Card với hiệu ứng Nút Delete bự ra từ từ
struct SwipeableCardView: View {
    let item: CustomButtonItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Nút Delete phía sau: Dãn to rộng ra theo lực vuốt ngón tay
            HStack(spacing: 0) {
                Spacer()
                if offset < 0 {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            // Biểu tượng phóng to từ từ theo độ vuốt
                            .scaleEffect(min(1.1, max(0.5, -offset / 70)))
                            // Chiều rộng nút mở rộng trực tiếp theo lực kéo ngón tay 👈
                            .frame(width: max(0, -offset))
                            .frame(maxHeight: .infinity)
                            .background(Color.red)
                            .cornerRadius(20)
                    }
                }
            }
            
            // Thẻ Nút chính phía trên
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
                    
                    Text("X: \(String(format: "%.1f", item.xValue))  •  Y: \(String(format: "%.1f", item.yValue))")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
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
                            // Vuốt sang trái: Kéo dãn nút Delete
                            offset = isSwiped ? gesture.translation.width - 85 : gesture.translation.width
                        } else if isSwiped && gesture.translation.width > 0 {
                            // Vuốt thu lại sang phải
                            offset = gesture.translation.width - 85
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.68)) {
                            if offset < -140 {
                                // Nếu vuốt kéo dãn quá đà -> Xoá luôn lập tức
                                onDelete()
                            } else if offset < -45 {
                                // Khung dừng mặc định để bấm nút Delete
                                offset = -85
                                isSwiped = true
                            } else {
                                // Thu về vị trí cũ
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
        }
    }
}

// MARK: - Add Button View
struct AddButtonView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var selectedIcon: String = "bolt.fill"
    @State private var xInput: String = ""
    @State private var yInput: String = ""

    var onSave: (CustomButtonItem) -> Void

    let sampleIcons = [
        "bolt.fill", "flame.fill", "star.fill", "gearshape.fill",
        "target", "lightbulb.fill", "shippingbox.fill", "bookmark.fill",
        "bell.fill", "shield.fill"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // 1. Nhập Tên
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

                    // 2. Chọn Icon
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

                    // 3. Nhập Tọa Độ
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TỌA ĐỘ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            HStack {
                                Text("X:")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16, weight: .semibold))
                                TextField("0.0", text: $xInput)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(16)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            
                            HStack {
                                Text("Y:")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16, weight: .semibold))
                                TextField("0.0", text: $yInput)
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

            // MARK: - Nút Lưu
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
