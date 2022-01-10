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
                   
                    let modelEntity = ModelEntity(mesh: .generateBox(size: width, cornerRadius: 0.03))
                            
                    modelEntity.transform = Transform(pitch: 0, yaw: 1, roll: 0)
                    
                    anchorEntity.addChild(modelEntity)
                    
                    
                    let text = MeshResource.generateText(movieRating.title,
                                          extrusionDepth: 0.01,
                                                    font: .systemFont(ofSize: 0.25),
                                          containerFrame: .zero,
                                               alignment: .center,
                                           lineBreakMode: .byWordWrapping)

                    let shader = UnlitMaterial(color: .white)
                    let textEntity = ModelEntity(mesh: text, materials: [shader])
                    textEntity.position.z += 0.6
                        
                    anchorEntity.addChild(textEntity)
                                      
                    arView.scene.addAnchor(anchorEntity)
                }
            }
    
        }
    }
    
}
