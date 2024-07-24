//
//  ObjectViewController.swift
//  glTFViewer
//
//  Created by Daegeon Choi on 7/25/24.
//

import UIKit
import SceneKit
import ARKit
import GLTFKit2
import CoreHaptics
import OSLog

class ObjectViewController: UIViewController {
    
    // MARK: Property
    public var assetURL: URL?
    private var assetDirectory: URL?
    private let assetContainerName = "AssetContainer"
    private var assetContainerNode = SCNNode()
    
    public let environmentLightName = "Neutral-small.hdr"
    public let environmentIntensity = 1.0
    
    // MARK: UI
    private var sceneView = SCNView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Object"
        self.view.backgroundColor = .white
        
        self.view.addSubview(sceneView)
        sceneView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assetContainerNode.name = assetContainerName
        sceneView.delegate = self
        
        self.configureSceneView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadAsset()
    }
    
}

extension ObjectViewController: SCNSceneRendererDelegate {
    
}

// MARK: Scene & 3D Model Configuration
extension ObjectViewController {
    private func configureSceneView() {
        sceneView.backgroundColor = .white
        sceneView.antialiasingMode = .multisampling4X
        sceneView.autoenablesDefaultLighting = false
        
        let scene = SCNScene()

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.wantsHDR = true
        camera.wantsExposureAdaptation = false
        camera.automaticallyAdjustsZRange = true
        cameraNode.camera = camera

        sceneView.allowsCameraControl = true
        sceneView.defaultCameraController.interactionMode = .orbitTurntable
        sceneView.defaultCameraController.pointOfView = cameraNode
        scene.rootNode.addChildNode(cameraNode)

        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.intensity = 400
        sunLight.color = UIColor.white
        sunLight.castsShadow = true
        sunLight.shadowMapSize = CGSize(width: 2048, height: 2048)
        sunLight.shadowBias = 2.0

        let sun = SCNNode()
        sun.light = sunLight
        scene.rootNode.addChildNode(sun)
        sun.look(at: SCNVector3(-0.25, -1, -0.25))

        scene.lightingEnvironment.contents = environmentLightName
        scene.lightingEnvironment.intensity = environmentIntensity

        sceneView.scene = scene
    }
    
    private func loadAsset() {
        guard let assetURL else { return }
        
        var accessingScopedResource = assetURL.startAccessingSecurityScopedResource()
        let options = assetDirectory != nil ? [ GLTFAssetLoadingOption.assetDirectoryURLKey : assetDirectory!] : [:]
        GLTFAsset.load(with: assetURL, options: options) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async {
                if accessingScopedResource {
                    assetURL.stopAccessingSecurityScopedResource()
                    accessingScopedResource = false
                }

                if status == .complete {
                    if let asset = maybeAsset {
                        let source = GLTFSCNSceneSource(asset: asset)
                        guard let assetScene = source.defaultScene else { return }
                        
                        for node in assetScene.rootNode.childNodes {
                            self.assetContainerNode.addChildNode(node)
                        }
                        
                        self.displayScene()
                    }
                } else if let error = maybeError {
                    print("\(#function): \(error.localizedDescription)")
                }

            }
        }
    }
    
    private func displayScene() {
        let view: SCNView! = sceneView
        let scene: SCNScene! = view.scene
        let pointOfView: SCNNode! = view.pointOfView

        DispatchQueue.main.async {
            scene.rootNode.addChildNode(self.assetContainerNode)

            let (sceneCenter, sceneRadius) = scene.rootNode.boundingSphere
            let simdCenter = simd_float3(Float(sceneCenter.x), Float(sceneCenter.y), Float(sceneCenter.z))
            pointOfView.simdPosition = sceneRadius * SIMD3<Float>(0, 0, 3) + simdCenter
            pointOfView.look(at: sceneCenter, up: SCNVector3(0, 10, 0), localFront: SCNVector3(0, 0, -10))

            /* TODO: 애니메이션
            view.prepare([scene!]) { _ in
                if let defaultAnimation = self.animations.first {
                    scene.rootNode.addAnimationPlayer(defaultAnimation.animationPlayer, forKey: nil)
                    defaultAnimation.animationPlayer.play()
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
             */
        }
    }
}
