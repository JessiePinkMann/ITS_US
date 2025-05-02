import Foundation
import Combine

final class TaskListViewModel: ObservableObject {
    // публичное:
    let category: Category
    
    // Published
    @Published var tasks: [Task] = []
    @Published var sort: Sort = .date
    @Published var showCompleted = true
    
    enum Sort { case date, alphabet, priority }
    
    // вычисляемая витрина
    var visible: [Task] {
        let filtered = showCompleted ? tasks
                                     : tasks.filter { !$0.isDone }
        switch sort {
        case .alphabet:
            return filtered.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .priority:
            let order: [TaskPriority] = [.high, .medium, .low]
            return filtered.sorted {
                order.firstIndex(of:$0.priority)! < order.firstIndex(of:$1.priority)!
            }
        case .date:
            return filtered.sorted { $0.createdDate < $1.createdDate }
        }
    }
    
    // Service
    private let service = TaskService()
    init(category: Category) {
        self.category = category
        service.observeTasks(categoryID: category.id ?? "") { [weak self] res in
            if case let .success(arr) = res {
                DispatchQueue.main.async { self?.tasks = arr }
            }
        }
    }
    
    // действия
    func toggle(_ t: Task) { var t = t; t.isDone.toggle(); service.update(t) }
    func delete(_ t: Task) { service.delete(t) }
    func add(_ t: Task)    { service.add(t) }
    func update(_ t: Task) { service.update(t) }
}
