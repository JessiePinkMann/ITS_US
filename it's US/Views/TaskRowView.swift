import SwiftUI

struct TaskRowView: View {
    let task: Task
    let toggle: () -> Void
    
    var body: some View {
        HStack {
            // Индикатор приоритета
            Circle()
                .fill(task.priority.color)
                .frame(width: 10, height: 10)
            
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .onTapGesture(perform: toggle)
            
            VStack(alignment:.leading) {
                Text(task.title)
                    .strikethrough(task.isDone)
                Text(task.createdDate, style: .date)
                    .font(.caption2).foregroundColor(.secondary)
                    .outline()
            }
            Spacer()
            Text(task.author.rawValue)
                .font(.caption2).foregroundColor(.secondary)
                .outline() 
        }
        .contentShape(Rectangle())
    }
}
