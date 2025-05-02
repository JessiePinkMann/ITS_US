import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    let category: Category
    var existing: Task? = nil
    let onSave: (Task) -> Void
    
    @State private var title = ""
    @State private var author = TaskAuthor.both
    @State private var priority = TaskPriority.medium
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Описание задачи", text:$title)
                Picker("Приоритет", selection:$priority) {
                    ForEach(TaskPriority.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Создатель", selection:$author) {
                    ForEach(TaskAuthor.allCases) { Text($0.rawValue).tag($0) }
                }
            }
            .navigationTitle(existing == nil ? "Новая задача" : "Редактирование")
            .toolbar {
                ToolbarItem(placement:.confirmationAction) {
                    Button("Сохранить") {
                        var task = existing ?? Task(
                            id:nil,
                            title:title,
                            isDone:false,
                            createdDate:Date(),
                            author:author,
                            priority:priority,
                            categoryID:category.id ?? ""
                        )
                        task.title    = title
                        task.author   = author
                        task.priority = priority
                        onSave(task)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in:.whitespaces).isEmpty)
                }
                ToolbarItem(placement:.cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
            .onAppear {
                if let t = existing {
                    title    = t.title
                    author   = t.author
                    priority = t.priority
                }
            }
        }
    }
}
