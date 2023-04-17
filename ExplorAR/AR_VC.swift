//
//  AR_VC.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 15/04/23.
//

import UIKit
import RealityKit
import ARKit
import Combine

class AR_VC: UIViewController, ARSessionDelegate {

    //@IBOutlet var sceneView: ARSCNView!
    var arView: ARView!
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        super.viewDidLoad()
            
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
            
        let configuration = ARObjectScanningConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
        arView.session.delegate = self
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let objectAnchor = anchor as? ARObjectAnchor else { continue }
            
            // Do something with the detected object
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let objectAnchor = anchor as? ARObjectAnchor else { continue }
            
            // Do something with the updated object
        }
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let objectAnchor = anchor as? ARObjectAnchor else { continue }
            
            // Do something with the removed object
        }
    }


    func loadModel(named modelName: String) {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") else {
            fatalError("Could not find the model in the app bundle.")
        }
        
        Entity.loadModelAsync(contentsOf: modelURL)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to load the model: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] model in
                self?.arView.scene.addAnchor(model as! HasAnchoring)
            }
            .store(in: &cancellables)
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
