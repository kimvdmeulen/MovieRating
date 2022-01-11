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
                    
                    let anchorEntity = AnchorEntity(anchor: imageAnchor)
                    
                    let width = Float(imageAnchor.referenceImage.physicalSize.width)
                    let height = Float(imageAnchor.referenceImage.physicalSize.height)
                    
                    var material = SimpleMaterial()
                    material.baseColor = MaterialColorParameter(_colorLiteralRed: 0.128, green: 0.128, blue: 0.128, alpha: 0.7)
                            
                    
                    let modelEntity = ModelEntity(mesh: .generateBox(width: width, height: 0.01, depth: height, cornerRadius: 0.03), materials: [material])
                    
                    
                    let text = MeshResource.generateText(rating.Title,
                                                         extrusionDepth: 0.001,
                                                         font: .systemFont(ofSize: CGFloat(width*0.05)),  containerFrame: .zero,
                                                         alignment: .left,
                                                         lineBreakMode: .byWordWrapping)
                    

                    let shader = UnlitMaterial(color: .white)
                    let textEntity = ModelEntity(mesh: text, materials: [shader])
                    
                    textEntity.orientation = simd_quatf(angle: -90,
                                                            axis: [1, 0, 0])
                    textEntity.position.z += 0.01
               
                    modelEntity.addChild(textEntity)
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
        
//        func ConnectOMDB(movie: String) -> MovieRating {
//            let urlString = "https://www.omdbapi.com/?t=" + movie + "&apikey=dc9e2a3c"
//            let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
//            var request = URLRequest(url: url)
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let task = URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
//                if let data = data {
//                    if let videoData = try? JSONDecoder().decode(MovieRating.self, from: data) as MovieRating {
//                        return videoData
//                    } else {
//                        print("Invalid Response")
//                    }
//                } else if let error = error {
//                    print("HTTP Request Failed \(error)")
//                }
//            }
//            task.resume()
//        }
    }
    
}
