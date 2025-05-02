import Foundation
import SwiftUICore
import FirebaseFirestore

enum TaskAuthor: String, Codable, CaseIterable, Identifiable {
    case egor  = "Егор"
    case anna  = "Анна"
    case both  = "Общее"
    var id: String { rawValue }
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case high   = "Высокий"
    case medium = "Средний"
    case low    = "Низкий"
    var id: String { rawValue }
    
    /// нежные цвета индикатора
    var color: Color {
        switch self {
        case .high:   return Color.red.opacity(0.6)      // мягкий красный
        case .medium: return Color.yellow.opacity(0.6)   // мягкий желтый
        case .low:    return Color.green.opacity(0.6)    // мягкий зелёный
        }
    }
}

struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var isDone: Bool
    var createdDate: Date
    var author: TaskAuthor
    var priority: TaskPriority
    var categoryID: String
}
