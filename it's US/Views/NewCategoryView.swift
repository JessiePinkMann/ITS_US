//  Views/NewCategoryView.swift
import SwiftUI

struct NewCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: CategoryListViewModel
    let existing: Category?
    
    // UI-state
    @State private var name = ""
    @State private var dateMode: DateMode = .none
    @State private var pickedDate = Date()
    @State private var creator: Creator = .common
    @State private var color:  Color = .blue.opacity(0.1)
    
    enum DateMode: String, CaseIterable, Identifiable {
        case none = "Без даты", today = "Сегодня", pick = "Выбрать"
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Название") {
                    TextField("Введите название", text:$name)
                }
                dateSection
                creatorSection
                colorSection
            }
            .navigationTitle(existing == nil ? "Новая категория" : "Редактирование")
            .toolbar { toolbar }
            .onAppear { if let e = existing { preload(e) } }
        }
    }
    
    // MARK: – Form Sections
    private var dateSection: some View {
        Section("Дата") {
            Picker("Дата", selection:$dateMode) {
                ForEach(DateMode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            if dateMode == .pick {
                DatePicker("", selection:$pickedDate, displayedComponents:.date)
                    .datePickerStyle(.graphical)
            }
        }
    }
    private var creatorSection: some View {
        Section("Создатель") {
            Picker("", selection:$creator) {
                ForEach(Creator.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }
    private var colorSection: some View {
        Section("Цвет фона") {
            ColorPicker("Выберите цвет", selection:$color, supportsOpacity:false)
                .frame(height: 40)
        }
    }
    
    // MARK: – Toolbar
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement:.navigationBarLeading) {
            Button("Отмена") { dismiss() }
        }
        ToolbarItem(placement:.navigationBarTrailing) {
            Button("Сохранить", action:save)
                .disabled(name.trimmingCharacters(in:.whitespaces).isEmpty)
        }
    }
    
    // MARK: – Logic
    private func preload(_ cat: Category) {
        name    = cat.name
        creator = cat.creator
        color   = cat.backgroundColor
        if let d = cat.createdDate { dateMode = .pick; pickedDate = d }
    }
    
    private func save() {
        let date: Date? = {
            switch dateMode {
            case .none: nil
            case .today: Date()
            case .pick: pickedDate
            }
        }()
        
        var cat = existing ?? Category(
            id: nil,
            name: name,
            createdDate: date,
            creator: creator,
            backgroundHex: nil
        )
        cat.name          = name
        cat.createdDate   = date
        cat.creator       = creator
        cat.backgroundColor = color
        
        existing == nil ? vm.add(cat) : vm.update(cat)
        dismiss()
    }
}
