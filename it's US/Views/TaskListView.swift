import SwiftUI

struct TaskListView: View {
    @StateObject private var vm: TaskListViewModel
    @State private var editing: Task?
    @State private var showNew = false
    
    init(category: Category) {
        _vm = StateObject(wrappedValue: TaskListViewModel(category: category))
    }
    
    var body: some View {
        List {
            ForEach(vm.visible) { t in
                TaskRowView(task:t) { vm.toggle(t) }
                    .swipeActions {
                        Button(role:.destructive) { vm.delete(t) } label:{
                            Label("Удалить", systemImage:"trash")
                        }
                    }
                    .contextMenu {
                        Button("Редактировать") { editing = t }
                    }
            }
        }
        .navigationTitle(vm.category.name)
        .toolbar { toolbar }
        .sheet(isPresented:$showNew) {
            NewTaskView(category: vm.category) { vm.add($0) }
        }
        .sheet(item:$editing) { t in
            NewTaskView(category: vm.category,
                        existing: t) { vm.update($0) }
        }
    }
    
    // MARK: toolbar
    @ToolbarContentBuilder                    // ⬅️ ключевая строка
    private var toolbar: some ToolbarContent {
        
        // левая кнопка-меню сортировки + переключатель «выполненные»
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Menu {
                Picker("Сортировка", selection: $vm.sort) {
                    Label("Дата",      systemImage: "calendar")
                        .tag(TaskListViewModel.Sort.date)
                    Label("А-Я",       systemImage: "textformat.abc")
                        .tag(TaskListViewModel.Sort.alphabet)
                    Label("Приоритет", systemImage: "flag")
                        .tag(TaskListViewModel.Sort.priority)
                }
                Toggle("Показывать выполненные", isOn: $vm.showCompleted)
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle")
            }
        }
        
        // правая кнопка «плюс»
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showNew = true } label: {
                Image(systemName: "plus")
            }
        }
    }
}
