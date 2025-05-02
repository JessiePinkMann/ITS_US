//  Models/Category.swift
import Foundation
import FirebaseFirestore
import SwiftUICore

enum Creator: String, Codable, CaseIterable, Identifiable {
    case common = "Общее ♥️"
    case egor   = "Егор 🌒"
    case anna   = "Анна ☀️"
    
    var id: String { rawValue }
}

/// Модель категории
struct Category: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    
    var name: String
    var createdDate: Date?
    var creator: Creator

    /// HEX-строка вида “#RRGGBB”; хранится в Firestore
    var backgroundHex: String?
    
    /// Удобное свойство для UI
    var backgroundColor: Color {
        get { Color(hex: backgroundHex) ?? Color.blue.opacity(0.1) }
        set { backgroundHex = newValue.toHexString() }
    }
}

// MARK: – Color ⇄ HEX
private extension Color {
    init?(hex: String?) {
        guard
            let hex = hex?.replacingOccurrences(of: "#", with: ""),
            hex.count == 6,
            let val = Int(hex, radix: 16)
        else { return nil }
        self.init(
            red  : Double((val >> 16) & 0xFF) / 255,
            green: Double((val >>  8) & 0xFF) / 255,
            blue : Double( val        & 0xFF) / 255
        )
    }
    func toHexString() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green:&g, blue:&b, alpha:nil)
        let v = (Int(r*255)<<16) | (Int(g*255)<<8) | Int(b*255)
        return String(format:"#%06X", v)
    }
}

