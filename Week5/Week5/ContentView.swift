import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab Sinh viên
            NavigationView {
                List(viewModel.students) { student in
                    VStack(alignment: .leading) {
                        Text(student.name).font(.headline)
                        Text("ID: \(student.id) | Email: \(student.email)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Sinh viên")
            }
            .tabItem {
                Label("Sinh viên", systemImage: "person.2")
            }
            .tag(0)
            
            // Tab Môn học
            NavigationView {
                List(viewModel.subjects) { subject in
                    VStack(alignment: .leading) {
                        Text(subject.name).font(.headline)
                        Text("ID: \(subject.id) | Học kỳ: \(subject.semester)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Môn học")
            }
            .tabItem {
                Label("Môn học", systemImage: "book")
            }
            .tag(1)
            
            // Tab Giảng viên
            NavigationView {
                List(viewModel.teachers) { teacher in
                    VStack(alignment: .leading) {
                        Text(teacher.name).font(.headline)
                        Text("ID: \(teacher.id) | Email: \(teacher.email)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Giảng viên")
            }
            .tabItem {
                Label("Giảng viên", systemImage: "person.badge.key")
            }
            .tag(2)
        }
    }
}