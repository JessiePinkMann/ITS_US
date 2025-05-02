//  Services/TaskService.swift
import FirebaseFirestore

final class TaskService {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let col = "tasks"
    
    // подписка
    func observeTasks(categoryID: String,
                      completion: @escaping (Result<[Task],Error>)->Void) {
        listener?.remove()
        listener = db.collection(col)
            .whereField("categoryID", isEqualTo: categoryID)
            .addSnapshotListener { snap, err in
                if let err { completion(.failure(err)); return }
                let tasks = snap?.documents.compactMap {
                    try? $0.data(as: Task.self)
                } ?? []
                completion(.success(tasks))
            }
    }
    
    func add(_ t: Task) {
        try? db.collection(col).addDocument(from: t)
    }
    
    func update(_ t: Task) {
        guard let id = t.id else { return }
        try? db.collection(col).document(id).setData(from: t, merge: true)
    }
    
    func delete(_ t: Task) {
        guard let id = t.id else { return }
        db.collection(col).document(id).delete()
    }
}
