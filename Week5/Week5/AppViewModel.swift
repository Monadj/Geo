import Foundation

class AppViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var subjects: [Subject] = []
    @Published var teachers: [Teacher] = []
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        students = DatabaseManager.shared.loadStudents()
        subjects = DatabaseManager.shared.loadSubjects()
        teachers = DatabaseManager.shared.loadTeachers()
    }
}