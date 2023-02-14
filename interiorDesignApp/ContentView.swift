//
//  ContentView.swift
//  interiorDesignApp
//
//  Created by Siddharth Dayaneni on 1/24/23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: String?
    @State private var modelPlacementConfirmed : String?
    
    var models: [String] = ["guitar", "chair", "tv", "plane"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelPlacementConfirmed: self.$modelPlacementConfirmed)
            
            if self.isPlacementEnabled{
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelPlacementConfirmed: self.$modelPlacementConfirmed)
            }
            else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
            


        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelPlacementConfirmed: String?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.modelPlacementConfirmed {
            print("adding new object")
            
            let filename = modelName + ".usdz"
            let modelEntity = try! ModelEntity.loadModel(named: modelName)
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            
            uiView.scene.addAnchor(anchorEntity)
            
            modelEntity.generateCollisionShapes(recursive: true)
            uiView.installGestures([.translation , .rotation, .scale], for: modelEntity)
            
            DispatchQueue.main.async{
                self.modelPlacementConfirmed = nil
            }
        }
    }
    
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    
    var models: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in Button(action: {
                        print("error with:  \(self.models[index])")
                        
                        self.selectedModel = self.models[index]
                        
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: UIImage(named: self.models[index])!)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    @Binding var modelPlacementConfirmed: String?
    
    var body: some View {
        HStack {
            Button(action: {
                print("Cancel Model Placement")
                self.resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            Button(action: {
                print("Confirm Model Placement")
                
                self.modelPlacementConfirmed = self.selectedModel
                self.resetPlacementParameters()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
