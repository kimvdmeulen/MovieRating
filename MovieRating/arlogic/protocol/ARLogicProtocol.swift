import SwiftUI
import RealityKit

protocol ARLogicProtocol: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView
    func updateUIView(_ uiView: ARView, context: Context)
}
