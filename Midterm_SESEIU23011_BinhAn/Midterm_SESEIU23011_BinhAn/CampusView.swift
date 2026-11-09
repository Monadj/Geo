//
//  PlaceDetailView.swift
//  Midterm_SESEIU23011_BinhAn
//
//  Created by MAY 01 on 9/11/26.
//


import SwiftUI

// MARK: - Màn hình Chi tiết địa điểm (Place Detail View)
struct PlaceDetailView: View {
    let place: CampusPlace
    @ObservedObject var manager: CampusDataManager
    
    var isFavorite: Bool { manager.favoriteIDs.contains(place.id) }
    var isVisited: Bool { manager.visitedIDs.contains(place.id) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Banner
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 180)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.code)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text(place.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                }
                
                // Action Buttons (Yêu thích, Check-in & Xem trên Map)
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Button(action: { manager.toggleFavorite(place) }) {
                            Label(
                                isFavorite ? "Đã yêu thích" : "Yêu thích",
                                systemImage: isFavorite ? "heart.fill" : "heart"
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isFavorite ? Color.primary : Color.clear)
                            .foregroundColor(isFavorite ? Color(.systemBackground) : .primary)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary, lineWidth: 1))
                        }
                        .cornerRadius(8)
                        
                        Button(action: { manager.toggleVisited(place) }) {
                            Label(
                                isVisited ? "Đã ghé thăm" : "Check-in điểm này",
                                systemImage: isVisited ? "checkmark.circle.fill" : "mappin.circle"
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isVisited ? Color.primary : Color.clear)
                            .foregroundColor(isVisited ? Color(.systemBackground) : .primary)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary, lineWidth: 1))
                        }
                        .cornerRadius(8)
                    }
                    
                    // Nút bấm mới: Xem trên bản đồ (Zoom tới vị trí)
                    Button(action: {
                        manager.navigateToMap(for: place)
                    }) {
                        Label("Xem trên bản đồ & Tìm đường", systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Content Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Thông tin chi tiết")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("Giờ hoạt động: \(place.hours)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    
                    HStack {
                        Image(systemName: "tag")
                        Text("Phân loại: \(place.category)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "location")
                        Text("Tọa độ: \(place.formattedCoordinates())")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Text(place.description)
                        .font(.body)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Chi tiết địa điểm")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subview Row Item
struct PlaceRowView: View {
    let place: CampusPlace
    let isFavorite: Bool
    let isVisited: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(place.name)
                        .font(.headline)
                    if isVisited {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                Text("\(place.code) • \(place.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(place.hours)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.primary)
                    .padding(8)
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding(.vertical, 4)
    }
}