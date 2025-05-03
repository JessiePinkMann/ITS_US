//  Views/CategoryListView.swift
import SwiftUI

struct CategoryListView: View {
    @StateObject private var vm = CategoryListViewModel()
    
    @State private var showNew    = false
    @State private var editingCat : Category? = nil
    @State private var showMemes  = false          // ← NEW
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(vm.visible) { cat in
                        NavigationLink { TaskListView(category: cat) } label: {
                            CategoryCardView(
                                category: cat,
                                onEdit:   { editingCat = cat },
                                onDelete: { vm.delete(cat) }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Категории")
            // поиск
            .searchable(text: $vm.search, prompt: "Поиск")
            // тулбар
            .toolbar { toolbarContent }
            // плавная анимация
            .animation(.easeInOut, value: vm.visible)
            // листы
            .sheet(isPresented: $showMemes) { MemesView() }
            .sheet(isPresented: Binding(
                get:{ showNew || editingCat != nil },
                set:{ v in showNew = v; if !v { editingCat = nil } })) {
                    NewCategoryView(vm: vm, existing: editingCat)
                }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: – Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // левое меню сортировки / фильтра
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                // сортировка
                Picker("Сортировка", selection: $vm.sort) {
                    Label("Дата", systemImage:"calendar")
                        .tag(CategoryListViewModel.Sort.date)
                    Label("А-Я", systemImage:"textformat.abc")
                        .tag(CategoryListViewModel.Sort.alphabet)
                }
                // фильтр
                Menu("Создатель") {
                    Button("Все", action:{ vm.filter = nil })
                    Divider()
                    Button("Анна ☀️", action:{ vm.filter = .anna })
                    Button("Егор 🌒", action:{ vm.filter = .egor })
                }
            } label: {
                Image(systemName:"arrow.up.arrow.down.circle")
            }
        }
        
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showMemes = true } label: {
                Image(systemName: "music.note")
            }
        }
        
        // «+» справа
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showNew = true } label: {
                Image(systemName:"plus")
            }
        }
    }
}
