import RealityKit
import ARKit
import SwiftUI

struct CustomARViewContainer: ARLogicProtocol {
    
    let arView = ARView(frame: .zero)

    func makeCoordinator() -> Coordinator {
        Coordinator(arView: arView)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let config = ARImageTrackingConfiguration()
        config.maximumNumberOfTrackedImages = 2
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
        
        init(arView: ARView) {
            self.arView = arView
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
               
                if let imageAnchor = anchor as? ARImageAnchor {
                    var rating: MovieRating = MovieRating(Title: "", Plot: "", imdbRating: "")
                    TConnectOMDB(movie: imageAnchor.referenceImage.name!, userCompletionHandler: { movie, error in
                        if let movie = movie {
                            rating = movie
                            print(movie)
                        }
                    })
                    // Shared properties for the elements
                    let shader = UnlitMaterial(color: .white)
                    let width = Float(imageAnchor.referenceImage.physicalSize.width)
                    let height = Float(imageAnchor.referenceImage.physicalSize.height/2)
                    let heightOffset = height/2
                    let widithOffset = width/2.3

                    // Anchor point where the Plane connects too
                    let anchorEntity = AnchorEntity(anchor: imageAnchor)
                    
                    // Plane material
                    var pMaterial = SimpleMaterial()
                    pMaterial.baseColor = MaterialColorParameter(_colorLiteralRed: 0.128, green: 0.128, blue: 0.128, alpha: 0.9)
                    let modelEntity = ModelEntity(mesh: .generateBox(width: width, height: 0.01, depth: height, cornerRadius: 0.03), materials: [pMaterial])
                    modelEntity.position.z += heightOffset
                    
                    // Title properties and positions
                    let title = MeshResource.generateText(rating.Title,
                                                         extrusionDepth: 0.001,
                                                         font: .systemFont(ofSize: CGFloat(width*0.08)),
                                                         containerFrame: .zero,
                                                         alignment: .left,
                                                         lineBreakMode: .byWordWrapping
                    )
                    let titleEntity = ModelEntity(mesh: title, materials: [shader])
                    titleEntity.orientation = simd_quatf(angle: -90, axis: [1, 0, 0])
                    titleEntity.position.z += -0.028
                    titleEntity.position.x += -0.03
                    titleEntity.position.y += 0.009
                    
                    // Rating properties and positions
                    
                    // Description properties and positions
                    let plot = MeshResource.generateText(rating.Plot,
                                                          extrusionDepth: 0.001,
                                                          font: .systemFont(ofSize: CGFloat(width*0.03)),
                                                          containerFrame: .zero,
                                                          alignment: .left,
                                                          lineBreakMode: .byWordWrapping
                    )
                    let plotEntity = ModelEntity(mesh: plot, materials: [shader])
                    plotEntity.position.z += -0.018
                    plotEntity.position.x += -widithOffset
                    plotEntity.position.y += 0.009

                    
                    textEntity.orientation = simd_quatf(angle: -90,
                                                            axis: [1, 0, 0])
                    textEntity.position.z += 0.01
                    
                    
                    var starMaterial = SimpleMaterial()
                    starMaterial.baseColor = try! .texture(.load(named: "Star"))

                    let starEntity = ModelEntity(mesh: .generatePlane(width: width*0.001, depth: height*0.001), materials: [starMaterial])
                        starEntity.generateCollisionShapes(recursive: true)
                   

                    // Adding the elements to the plane
                    modelEntity.addChild(plotEntity)
                    modelEntity.addChild(titleEntity)
                    modelEntity.addChild(starEntity)
                    anchorEntity.addChild(modelEntity)
                    
                    arView.scene.addAnchor(anchorEntity)
                    
                    
                }
            }
        }
        
        func TConnectOMDB(movie: String, userCompletionHandler: @escaping (MovieRating?, Error?) -> Void) {
            let urlString = "https://www.omdbapi.com/?t=" + movie + "&apikey=dc9e2a3c"
            let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                if let data = data {
                    if let videoData = try? JSONDecoder().decode(MovieRating.self, from: data) as MovieRating {
                        userCompletionHandler(videoData, nil)
                    } else {
                        print("Invalid Response")
                    }
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                }
            })
            task.resume()
        }
    }
}
