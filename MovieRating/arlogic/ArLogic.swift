import RealityKit
import ARKit

struct CustomARViewContainer: ARLogicProtocol {
    let arView = ARView(frame: .zero)

    func makeCoordinator() -> Coordinator {
        Coordinator(arView: arView)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let config = ARImageTrackingConfiguration()
        config.maximumNumberOfTrackedImages = 1
        config.isAutoFocusEnabled = true
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "TrackingImages", bundle: nil) else {
            fatalError("Images not found")
        }
        config.trackingImages = trackingImages
        
        arView.session.delegate = context.coordinator
        arView.session.run(config, options: [])

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        let arView: ARView!
        let movieRating = MovieRating(title: "I Am Greta",rating: 8.8)
        
        init(arView: ARView) {
            self.arView = arView
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            
            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    
                    let anchorEntity = AnchorEntity(anchor: imageAnchor)
                    
                    let width = Float(imageAnchor.referenceImage.physicalSize.width)
                    let height = Float(imageAnchor.referenceImage.physicalSize.height)
                    
                    var material = SimpleMaterial()
                    material.baseColor = MaterialColorParameter(_colorLiteralRed: 0.128, green: 0.128, blue: 0.128, alpha: 0.7)
                            
                    
                    let modelEntity = ModelEntity(mesh: .generateBox(width: width, height: 0.05, depth: height, cornerRadius: 0.015), materials: [material])
                    
             
                    anchorEntity.addChild(modelEntity)
                    
                    let text = MeshResource.generateText(movieRating.title,
                                          extrusionDepth: 0.02,
                                                         font: .systemFont(ofSize: CGFloat(width*0.05)),
                                          containerFrame: .zero,
                                               alignment: .left,
                                           lineBreakMode: .byWordWrapping)

                    let shader = UnlitMaterial(color: .white)
                    let textEntity = ModelEntity(mesh: text, materials: [shader])
                    textEntity.orientation = simd_quatf(angle: -90,
                                                            axis: [1, 0, 0])
               
                    anchorEntity.addChild(textEntity)
                    arView.scene.addAnchor(anchorEntity)
                }
            }
    
        }
    }
    
}
