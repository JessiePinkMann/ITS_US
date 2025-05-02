//  Views/CategoryListView.swift
import SwiftUI

struct CategoryListView: View {
    @StateObject private var vm = CategoryListViewModel()
    
    @State private var showNew = false
    @State private var editing : Category? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(vm.visible) { cat in
                        NavigationLink {
                            TaskListView(category: cat)
                        } label: {
                            CategoryCardView(
                                category: cat,
                                onEdit:   { editing = cat },
                                onDelete: { vm.delete(cat) }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Категории")
            //------------------------------------------------------------------
            .searchable(text: $vm.search, prompt: "Поиск")
            //------------------------------------------------------------------
            .toolbar {
                // левое меню сортировки/фильтра
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        // sort block
                        Picker("Сортировка", selection: $vm.sort) {
                            Label("Дата", systemImage:"calendar")
                                .tag(CategoryListViewModel.Sort.date)
                            Label("А-Я", systemImage:"textformat.abc")
                                .tag(CategoryListViewModel.Sort.alphabet)
                        }
                        // filter creator
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
                // + справа
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showNew = true } label: {
                        Image(systemName:"plus")
                    }
                }
            }
            .animation(.easeInOut, value: vm.visible)
            //------------------------------------------------------------------
            .sheet(isPresented: Binding(
                get:{ showNew || editing != nil },
                set:{ v in showNew = v; if !v { editing = nil } })
            ) {
                NewCategoryView(
                    vm: vm,
                    existing: editing
                )
            }
        }
    }
}
