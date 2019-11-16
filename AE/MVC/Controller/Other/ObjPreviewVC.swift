//
//  ObjPreviewVC.swift
//  AE
//
//  Created by MAC_MINI_6 on 08/06/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ModelIO
import GLTFSceneKit

class ObjPreviewVC: BaseVC {

  @IBOutlet weak var scnView: SCNView!
  @IBOutlet weak var btnWeb: UIButton!
  
  var obj: Object?
  
  override func viewDidLoad() {
    super.viewDidLoad()
     loadObjToScene()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }

  
  @IBAction func btnBackAction(_ sender: UIButton) {
    popVC()
  }
  
  @IBAction func btnWebAction(_ sender: UIButton) {
    presentSafariVC(urlString: /obj?.objectLink)
  }
  
  func loadObjToScene() {
//    let scene = SCNScene()
//
//    let cameraNode = SCNNode()
//    cameraNode.camera = SCNCamera()
//    scene.rootNode.addChildNode(cameraNode)
//
//    cameraNode.position = SCNVector3.init(0, 0, 15)
//
//    scnView.scene = scene
//    scnView.allowsCameraControl = true
//    scnView.showsStatistics = false
//    scnView.backgroundColor = UIColor.white
//    scnView.autoenablesDefaultLighting = true
//
//    let mdlAsset = MDLAsset(url: URL(fileURLWithPath: "\(MZUtility.baseFilePath)/\(/obj?.objectUrl?.fileName)"))
//    print("\(MZUtility.baseFilePath)/\(/obj?.objectUrl?.fileName)")
//
//    let scatteringFunction = MDLScatteringFunction.init()
//    let material = MDLMaterial.init(name: "baseMaterial", scatteringFunction: scatteringFunction)
//
//
//    material.setTextureProperties(textures: [.baseColor : /obj?.objectUrl?.textureName])
//
//    for mesh in ((mdlAsset.object(at: 0) as? MDLMesh)?.submeshes as? [MDLSubmesh]) ?? [] {
//      print("Mesh Name: \(mesh.name)")
//      mesh.material = material
//    }
//
//    mdlAsset.loadTextures()
//
//
//    let objectNode = SCNNode(mdlObject: mdlAsset.object(at: 0))
//    objectNode.scale = SCNVector3(2, 2, 2)
//    objectNode.position = SCNVector3(0, 0, 0)
//
//    scene.rootNode.addChildNode(objectNode)
    
    btnWeb.isHidden = /obj?.objectLink == ""
    
    do {
      
      let urlString = "\(MZUtility.baseFilePath)/\(/obj?.objectUrl?.fileName)"
      
      let sceneSource = try GLTFSceneSource.init(url: URL.init(fileURLWithPath: /urlString))
      let scene = try sceneSource.scene()
//      scene.rootNode.position
//      scene.rootNode.scale = scene.rootNode.scale
//      scene.rootNode.position = scene.rootNode.position
      scene.rootNode.scale = SCNVector3(0.15, 0.15, 0.15)
      scene.rootNode.position = SCNVector3(0, -0.2, -0.8)
      let cameraNode = SCNNode()
      cameraNode.camera = SCNCamera()
      cameraNode.position = SCNVector3.init(0, 0, 15)
      scene.rootNode.addChildNode(cameraNode)
      scnView.scene = scene
      scnView.allowsCameraControl = true
      scnView.showsStatistics = false
      scnView.backgroundColor = UIColor.white
      scnView.autoenablesDefaultLighting = true
    } catch {
      print("\(error.localizedDescription)")
      return
    }
  }
  
}


extension MDLMaterial {
  func setTextureProperties(textures: [MDLMaterialSemantic:String]) -> Void {
    for (key,value) in textures {
      let url = URL(fileURLWithPath: "\(MZUtility.baseFilePath)/\(value)")
      let property = MDLMaterialProperty(name:value, semantic: key, url: url)
      self.setProperty(property)
    }
  }
}
