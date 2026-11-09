import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    // Đọc danh sách Sinh viên từ file students.txt
    func loadStudents() -> [Student] {
        guard let path = Bundle.main.path(forResource: "students", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        
        let lines = content.components(separatedBy: .newlines).dropFirst() // Bỏ qua dòng tiêu đề (Header)
        var students: [Student] = []
        
        for line in lines {
            let columns = line.components(separatedBy: ",")
            if columns.count >= 3 {
                let student = Student(id: columns[0], name: columns[1], email: columns[2])
                students.append(student)
            }
        }
        return students
    }
    
    // Đọc danh sách Môn học từ file subjects.txt
    func loadSubjects() -> [Subject] {
        guard let path = Bundle.main.path(forResource: "subjects", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        
        let lines = content.components(separatedBy: .newlines).dropFirst()
        var subjects: [Subject] = []
        
        for line in lines {
            let columns = line.components(separatedBy: ",")
            if columns.count >= 3 {
                let subject = Subject(id: columns[0], name: columns[1], semester: columns[2])
                subjects.append(subject)
            }
        }
        return subjects
    }
    
    // Đọc danh sách Giảng viên từ file teachers.txt
    func loadTeachers() -> [Teacher] {
        guard let path = Bundle.main.path(forResource: "teachers", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        
        let lines = content.components(separatedBy: .newlines).dropFirst()
        var teachers: [Teacher] = []
        
        for line in lines {
            let columns = line.components(separatedBy: ",")
            if columns.count >= 3 {
                let teacher = Teacher(id: columns[0], name: columns[1], email: columns[2])
                teachers.append(teacher)
            }
        }
        return teachers
    }
}