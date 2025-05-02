//  Views/CategoryCardView.swift
import SwiftUI

struct CategoryCardView: View {
    let category: Category
    var onEdit:   () -> Void
    var onDelete: () -> Void
    
    private let df: DateFormatter = {
        let d = DateFormatter(); d.dateStyle = .short; return d
    }()
    
    var body: some View {
        ZStack {
            // фон
            category.backgroundColor
            
            // контент
            VStack(spacing: 6) {
                // ⬆️  БОЛЬШЕ: было .headline → стало .title2.bold()
                Text(category.name)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                    .outline()
                
                if let bottom = buildBottom() {
                    // ⬆️  БОЛЬШЕ: было .caption → стало .callout
                    Text(bottom)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .outline()
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
        }
        .clipShape(Capsule())
        .frame(height: 80)              // чуть выше, чтобы текст не резался
        // свайп / меню
        .swipeActions { Button(role:.destructive, action:onDelete){
            Label("Удалить", systemImage:"trash") } }
        .contextMenu {
            Button("Редактировать", action:onEdit)
            Button("Удалить", role:.destructive, action:onDelete)
        }
    }
    
    private func buildBottom() -> String? {
        switch (category.createdDate, category.creator) {
        case let (d?, c):
            let date = df.string(from: d)
            let who  = c == .common ? "Общее" : "Создатель: \(c.rawValue)"
            return "\(date) · \(who)"
        case (nil, let c) where c != .common:
            return "Создатель: \(c.rawValue)"
        case (nil, .common):
            return "Общее"
        default:
            return nil
        }
    }
}
