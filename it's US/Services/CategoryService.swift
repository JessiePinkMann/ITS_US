//  Services/CategoryService.swift
import Foundation
import FirebaseFirestore
import FirebaseStorage

final class CategoryService {
    private let db  = Firestore.firestore()
    private let st  = Storage.storage().reference()
    private let col = "categories"
    
    //–––– MARK: чтение ––––
    func fetchCategories(completion: @escaping (Result<[Category],Error>) -> Void) {
        // убрали orderBy, чтобы документы без createdDate тоже пришли
        db.collection(col).addSnapshotListener { snap, err in
            if let err = err { completion(.failure(err)); return }
            let cats = snap?.documents.compactMap {
                try? $0.data(as: Category.self)
            } ?? []
            completion(.success(cats))
        }
    }
    
    //–––– MARK: добавление / обновление ––––
    func createCategory(_ c: Category, completion: @escaping (Error?) -> Void) {
        write(c, completion: completion)
    }
    func updateCategory(_ c: Category, completion: @escaping (Error?) -> Void) {
        write(c, completion: completion)
    }
    private func write(_ c: Category, completion: @escaping (Error?)->Void) {
        do {
            if let id = c.id {
                try db.collection(col).document(id).setData(from: c, merge: true, completion: completion)
            } else {
                _ = try db.collection(col).addDocument(from: c, completion: completion)
            }
        } catch { completion(error) }
    }
    
    //–––– MARK: удаление ––––
    // MARK: – удаление
    func deleteCategory(_ c: Category, completion: @escaping (Error?) -> Void) {
        guard let id = c.id else { completion(nil); return }
        db.collection(col).document(id).delete(completion: completion)
        // фото больше не используем – ничего чистить в Storage не нужно
    }

    
    //–––– MARK: загрузка картинки ––––
    func upload(image: UIImage,
                for id: String = UUID().uuidString,
                completion: @escaping (Result<URL,Error>) -> Void)
    {
        // ── 1. нормализуем в обычный 8-бит sRGB JPEG без прозрачности ──
        guard let data = image.normalizedJPEG(quality: 0.8) else {
            completion(.failure(NSError(domain:"JPEGConv", code:0))); return
        }
        
        // ── 2. кладём в Storage ──
        let ref  = Storage.storage()
            .reference(withPath: "categoryImages/\(id).jpg")
        let meta = StorageMetadata(); meta.contentType = "image/jpeg"
        
        //  замена только одной строки внутри ref.putData
        ref.putData(data, metadata: meta) { _, err in
            if let err {
                print("❌ Storage upload error:", err.localizedDescription)     // <<< LOG
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            ref.downloadURL { url, err in
                if let err {
                    print("❌ downloadURL error:", err.localizedDescription)
                    DispatchQueue.main.async { completion(.failure(err)) }
                } else if let url {
                    print("✅ Uploaded URL:", url.absoluteString)               // <<< LOG
                    DispatchQueue.main.async { completion(.success(url)) }
                }
            }
        }

    }
}

private extension UIImage {
    func normalizedJPEG(quality q: CGFloat) -> Data? {
        // рисуем в непрозрачный sRGB-контекст, избегая HDR/alpha
        let fmt = UIGraphicsImageRendererFormat.default()
        fmt.preferredRange = .standard
        fmt.opaque = true
        let r = UIGraphicsImageRenderer(size: size, format: fmt)
        let img = r.image { _ in self.draw(in: CGRect(origin: .zero, size: size)) }
        return img.jpegData(compressionQuality: q)
    }
}
