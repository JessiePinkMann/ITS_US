//  ViewModels/CategoryListViewModel.swift
import Foundation
import Combine
import UIKit

final class CategoryListViewModel: ObservableObject {
    // источник
    @Published private(set) var categories: [Category] = []
    
    // состояние UI
    @Published var sort:     Sort   = .date
    @Published var filter:   Creator? = nil        
    @Published var search:   String = ""
    
    enum Sort { case date, alphabet }
    
    // вычисляемая витрина
    var visible: [Category] {
        categories
            .filter { filter == nil || $0.creator == filter! }
            .filter { search.isEmpty ||
                      $0.name.lowercased().contains(search.lowercased()) }
            .sorted { lhs, rhs -> Bool in
                switch sort {
                case .alphabet:
                    return lhs.name.lowercased() < rhs.name.lowercased()
                case .date:
                    return (lhs.createdDate ?? .distantFuture) <
                           (rhs.createdDate ?? .distantFuture)
                }
            }
    }
    
    //------------------------------------------------------------------
    private let service = CategoryService()
    init() {
        service.fetchCategories { [weak self] res in
            if case let .success(cats) = res {
                DispatchQueue.main.async { self?.categories = cats }
            }
        }
    }
    
    //------------------------------------------------------------------
    // прокси CRUD
    func add   (_ c: Category){ service.createCategory(c){ _ in } }
    func update(_ c: Category){ service.updateCategory(c){ _ in } }
    func delete(_ c: Category){ service.deleteCategory(c){ _ in } }
    
    // image upload
    func upload(image: UIImage, completion:@escaping(URL?)->Void) {
        service.upload(image:image) { res in
            switch res {
            case .success(let url): completion(url)
            case .failure:          completion(nil)
            }
        }
    }
}
