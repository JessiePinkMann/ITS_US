import SwiftUI
import UIKit

/// Интерактивный кроп-вид: жест «pinch+pan» внутри капсулы.
/// Возвращает обрезанный JPEG через `onCropped`.
struct CropCapsuleView: View {
    let source: UIImage
    let onCropped: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // размер капсулы = такой же, как карточка для текущего устройства
    private var capsuleSize: CGSize {
        let w = min(UIScreen.main.bounds.width - 32, 500)
        return .init(width: w, height: 70)   // высота карточки = 70
    }
    
    // state
    @State private var offset = CGSize.zero
    @State private var currentScale: CGFloat = 1
    @GestureState private var gestureDrag = CGSize.zero
    @GestureState private var gestureScale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Capsule()
                    .fill(Color.clear)
                    .frame(width: capsuleSize.width, height: capsuleSize.height)
                    .overlay(
                        Image(uiImage: source)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(currentScale * gestureScale)
                            .offset(x: offset.width + gestureDrag.width,
                                    y: offset.height + gestureDrag.height)
                    )
                    .clipped()
            }
            .gesture(dragGesture.simultaneously(with: pinchGesture))
            
            HStack {
                Button("Отмена") { dismiss() }
                Spacer()
                Button("Сохранить") {
                    let img = renderCapsule()
                    onCropped(img)
                    dismiss()
                }
            }
            .font(.headline)
            .padding(.horizontal)
        }
        .padding()
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: – Gestures
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($gestureDrag) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                offset.width  += value.translation.width
                offset.height += value.translation.height
            }
    }
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                currentScale *= value
            }
    }
    
    // MARK: – Render SwiftUI → UIImage
    private func renderCapsule() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: capsuleSize)
        return renderer.image { ctx in
            // background
            UIBezierPath(roundedRect: CGRect(origin: .zero,
                                             size: capsuleSize),
                         cornerRadius: capsuleSize.height / 2).addClip()
            // draw
            ctx.cgContext.translateBy(x: capsuleSize.width/2,
                                      y: capsuleSize.height/2)
            ctx.cgContext.scaleBy(x: currentScale,
                                  y: currentScale)
            ctx.cgContext.translateBy(x: offset.width + gestureDrag.width,
                                      y: offset.height + gestureDrag.height)
            source.draw(in: CGRect(
                x: -source.size.width/2,
                y: -source.size.height/2,
                width: source.size.width,
                height: source.size.height))
        }
    }
}
