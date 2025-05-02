//  Utilities/ImagePicker.swift
import SwiftUI
import PhotosUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentation
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ImagePicker
        init(_ p: ImagePicker) { self.parent = p }
        
        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {
            if let item = results.first,
               item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                item.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
                    guard let self, let ui = obj as? UIImage else { return }
                    DispatchQueue.main.async { self.parent.image = ui }
                }
            }
            parent.presentation.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var cfg = PHPickerConfiguration()
        cfg.filter = .images
        cfg.selectionLimit = 1
        let picker = PHPickerViewController(configuration: cfg)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiVC: PHPickerViewController, context: Context) {}
}
