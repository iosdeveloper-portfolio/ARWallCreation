//
//  ViewController.swift
//  ArtGallery
//
//  Created by TechFlitter Solutions on 02/07/18.
//  Copyright © 2018 TechFlitter Solutions. All rights reserved.
//
//
import UIKit
import SceneKit
import ARKit


let options = [ARSCNDebugOptions.showFeaturePoints, .showPhysicsShapes, .showSkeletons, .showWireframe, .showBoundingBoxes, ARSCNDebugOptions.showWorldOrigin]
class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var walls: [SCNNode] = [SCNNode]()
    var angleZ : Float = 0
    var rotateLeftButton : UIButton?
    var rotateRightButton : UIButton?
    var reloadButton : UIButton?
    var deleteButton : UIButton?
    var cancelButton : UIButton?
    
    var focusSquare : FocusSquare?
    var previousTranslation = CGPoint.init(x: 0, y: 0)
    var selectedNode : SCNNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        addTapGestureToSceneView()
        
        setupFocusSquare()
        
        
        reloadButton = UIButton(frame: CGRect(x: self.sceneView.frame.width - 60, y: 30, width: 50 , height: 50))
        reloadButton?.addTarget(self, action: #selector(reload(sender:)), for: [.touchUpInside])
        self.view .addSubview(reloadButton!)
        reloadButton?.isHidden = true
        reloadButton?.setImage(#imageLiteral(resourceName: "refresh-80"), for: .normal)
        
        rotateLeftButton = UIButton(frame: CGRect(x: self.sceneView.frame.width - 60, y: self.sceneView.frame.height - 60, width: 50 , height: 50))
        rotateLeftButton?.addTarget(self, action: #selector(rotateLeft(sender:)), for: [.touchUpInside])
        self.view .addSubview(rotateLeftButton!)
        rotateLeftButton?.isHidden = true
        rotateLeftButton?.setImage(#imageLiteral(resourceName: "left-arrow-120"), for: .normal)
        
        rotateRightButton = UIButton(frame: CGRect(x: self.sceneView.frame.width - 60, y: self.sceneView.frame.height - 120, width: 50 , height: 50))
        rotateRightButton?.addTarget(self, action: #selector(rotateRight(sender:)), for: [.touchUpInside])
        self.view .addSubview(rotateRightButton!)
        rotateRightButton?.isHidden = true
        rotateRightButton?.setImage(#imageLiteral(resourceName: "right-arrow-120"), for: .normal)
        
        deleteButton = UIButton(frame: CGRect(x: 10, y: self.sceneView.frame.height - 60, width: 50 , height: 50))
        deleteButton?.addTarget(self, action: #selector(deleteNode(sender:)), for: [.touchUpInside])
        self.view .addSubview(deleteButton!)
        deleteButton?.isHidden = true
        deleteButton?.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        
        cancelButton = UIButton(frame: CGRect(x: 10, y: 30, width: 50 , height: 50))
        cancelButton?.addTarget(self, action: #selector(removeFocusFromNode(node:)), for: [.touchUpInside])
        self.view .addSubview(cancelButton!)
        cancelButton?.isHidden = true
        cancelButton?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
    }
    
    @objc func rotateLeft(sender: Any){
        guard let wall = selectedNode else{
            return
        }
        let action = SCNAction.rotateTo(x: CGFloat(wall.eulerAngles.x), y: CGFloat(wall.eulerAngles.y) - CGFloat(0.1), z: CGFloat(wall.eulerAngles.z), duration: 0.1)
        wall.runAction(action)
        
    }
    
    @objc func rotateRight(sender: Any){
        guard let wall = selectedNode else{
            return
        }
        let action = SCNAction.rotateTo(x: CGFloat(wall.eulerAngles.x), y: CGFloat(wall.eulerAngles.y) + CGFloat(0.1), z: CGFloat(wall.eulerAngles.z), duration: 0.1)
        wall.runAction(action)
        
    }
    
    @objc func deleteNode(sender: Any){
        guard let wall = selectedNode else{
            return
        }
        removeFocusFromNode(node: wall)
        wall.removeFromParentNode()
        
        rotateLeftButton?.isHidden = true
        rotateRightButton?.isHidden = true
        deleteButton?.isHidden = true
        if(walls.first?.childNodes.count == 1){
            reload(sender: sender)
        }
    }
    
    @objc func reload(sender: Any){
        for wall in walls {
            wall.removeFromParentNode()
        }
        walls.removeAll()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.run(configuration, options: .removeExistingAnchors)
        
        reloadButton?.isHidden = true
        rotateLeftButton?.isHidden = true
        rotateRightButton?.isHidden = true
        deleteButton?.isHidden = true
        cancelButton?.isHidden = true
        focusSquare?.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:-  gesture recognizers
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addFrameToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.moveOnYAxis(recogniser:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.resize(recognizer:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    @objc func moveOnYAxis(recogniser: UIPanGestureRecognizer){
        recogniser.minimumNumberOfTouches = 1
        recogniser.maximumNumberOfTouches = 1
        if recogniser.numberOfTouches == 1 {
            let view = self.view as! SCNView
            
            guard let frame = selectedNode?.childNode(withName: "framePlane", recursively: true) else {
                return
            }
            let frameToMove = frame
            let translation = recogniser.translation(in: view)
            
            var dx = previousTranslation.x - translation.x
            var dy = previousTranslation.y - translation.y
            
            dx = dx / 100
            dy = dy / 5000
            print(dx,dy)
            
            let cammat = frameToMove.transform
            //            let transmat = SCNMatrix4MakeTranslation(Float(dx), 0, Float(dy))
            let transmat1 = SCNMatrix4MakeTranslation(0, Float(dy), 0)
            switch recogniser.state {
            case .began:
                previousTranslation = translation
                break;
            case .changed:
                frameToMove.transform = SCNMatrix4Mult(transmat1, cammat)
                break
            default: break
            }
        }
    }
    
    @objc func resize(recognizer: UIPinchGestureRecognizer){
        guard let frameToResize = selectedNode else{
            return
        }
        let action = SCNAction.scale(by: recognizer.scale, duration: 0.1)
        frameToResize.runAction(action)
        recognizer.scale = 1
    }
    
    @objc func addFrameToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        
        let nodeHits = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.categoryBitMask: 101])
        /*if let frameNode = nodeHits.first?.node, frameNode.name == "framePlane", let wall = frameNode.parent, wall.name == "wall" {
         setFocusToNode(node: wall)
         rotateRightButton?.isHidden = false
         rotateLeftButton?.isHidden = false
         deleteButton?.isHidden = false
         return
         }
         else if let wallNode = nodeHits.first?.node, wallNode.name == "wall" {
         setFocusToNode(node: wallNode)
         rotateRightButton?.isHidden = false
         rotateLeftButton?.isHidden = false
         deleteButton?.isHidden = false
         return
         }
         else if nodeHits.first?.node.name == "focusSquare"{
         return
         }
         */
        if let frameNode = nodeHits.first?.node, frameNode.name == "framePlane" {
            setFocusToNode(node: frameNode)
            rotateRightButton?.isHidden = false
            rotateLeftButton?.isHidden = false
            deleteButton?.isHidden = false
            return
        }
        else if nodeHits.first?.node.name == "focusSquare"{
            return
        }
        
        if walls.count > 0 {
            return
        }
        
        let hitTestResults = sceneView.hitTest(tapLocation, types: [.featurePoint])
        guard let _ = hitTestResults.first, !focusSquare!.isHidden else{
            return
        }
        
        //        let wallNode = getGalleryWallsWith(count: 6)
        
        let wallNode = getWallNode()
        wallNode.position = (focusSquare?.position)!
        let angle = sceneView.session.currentFrame?.camera.eulerAngles
        wallNode.eulerAngles.y = angle!.y
        walls.append(wallNode)
        
        angleZ = 0
        sceneView.scene.rootNode.addChildNode(wallNode)
        
        reloadButton?.isHidden = false
        focusSquare?.isHidden = true
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    var nodeTransform : SCNMatrix4?
    
    func setFocusToNode(node: SCNNode) {
        if (selectedNode != nil) {
            removeFocusFromNode(node: selectedNode!)
        }
        selectedNode = node
        nodeTransform = node.transform
        let base = selectedNode?.childNode(withName: "base", recursively: true)
        base?.geometry?.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.7)
        
        let action = SCNAction.move(by: SCNVector3(0, 0, 0.5), duration: 0.5)
        node.runAction(action)
        cancelButton?.isHidden = false
        rotateLeftButton?.isHidden = false
        rotateRightButton?.isHidden = false
        deleteButton?.isHidden = false
    }
    
    @objc func removeFocusFromNode(node: SCNNode) {
        let base = selectedNode?.childNode(withName: "base", recursively: true)
        base?.geometry?.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.0)
        selectedNode?.transform = nodeTransform!
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = selectedNode?.transform
        animation.toValue = nodeTransform!
        animation.duration = 0.5
        selectedNode?.addAnimation(animation, forKey: nil)
        cancelButton?.isHidden = true
        rotateLeftButton?.isHidden = true
        rotateRightButton?.isHidden = true
        deleteButton?.isHidden = true
        selectedNode = nil
    }
    
    func getGalleryWallsWith(count: Int) -> SCNNode {
        
        let floor = SCNNode(geometry: SCNBox(width: 3, height: 0.1, length: 3, chamferRadius: 0))
        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.3)
        floor.position = focusSquare!.position
        
        let floorBound = getBoundsOfNode(node: floor)
        floor.pivot = SCNMatrix4MakeTranslation(0, -floorBound.y/2,0)
        floor.eulerAngles.y = sceneView.session.currentFrame!.camera.eulerAngles.y
        
        let radius : Double = Double(floorBound.x / 2)
        let angle = SCNVector3(0,0,0)
        let wallBounds = getBoundsOfNode(node: getWallNode())
        for i in 0..<count {
            
            let positionRadian = deg2rad(Double(i) * Double(-(wallBounds.x * 30)))
            
            let x = 0 + radius * cos(positionRadian)
            let z = 0 + radius * sin(positionRadian)
            
            let wall = getWallNode()
            wall.position = SCNVector3(x,0,z)
            floor.addChildNode(wall)
        }
        return floor
    }
    
    func getBoundsOfNode(node: SCNNode) -> SCNVector3 {
        let (minVec, maxVec) = node.boundingBox
        let nodeBounds = SCNVector3(
            x: maxVec.x - minVec.x,
            y: maxVec.y - minVec.y,
            z: maxVec.z - minVec.z)
        return nodeBounds
    }
    
    func getWallNode() -> SCNNode {
        let wallScene = SCNScene(named: "art.scnassets/wallScene.scn")!
        let wallNode = wallScene.rootNode.childNode(withName: "wall", recursively: true)
        
        
        if let (minVec, maxVec) = wallNode?.boundingBox {
            let bound = SCNVector3(
                x: maxVec.x - minVec.x,
                y: maxVec.y - minVec.y,
                z: maxVec.z - minVec.z)
            
            wallNode?.pivot = SCNMatrix4MakeTranslation(0, -bound.y/2,0)
        }
        wallNode?.categoryBitMask = 101
        return wallNode!
    }
    
    // MARK: - Focus Square
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        focusSquare?.name = "focusSquare"
        sceneView.scene.rootNode.addChildNode(focusSquare!)
    }
    
    func updateFocusSquare() {
        
        focusSquare?.unhide()
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(self.sceneView.bounds.mid, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.sceneView.session.currentFrame?.camera)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: 10, height: 10)
        
        plane.materials.first?.diffuse.contents = UIColor.white.withAlphaComponent(0.3)
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        planeNode.categoryBitMask = 100
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    }
}

// MARK: - Position Measure
extension ViewController {
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 5, minDistance: 0.1, maxDistance: 50.0)
        
        // 过滤特征点
        let featureCloud = sceneView.fliterWithFeatures(highQualityfeatureHitTestResults)
        
        if featureCloud.count >= 3 {
            let warpFeatures = featureCloud.map({ (feature) -> NSValue in
                return NSValue(scnVector3: feature)
            })
            
            // 根据特征点进行平面推定
            let detectPlane = planeDetectWithFeatureCloud(featureCloud: warpFeatures)
            
            var planePoint = SCNVector3Zero
            if detectPlane.x != 0 {
                planePoint = SCNVector3(Int(detectPlane.w/detectPlane.x),0,0)
            }else if detectPlane.y != 0 {
                planePoint = SCNVector3(0,Int(detectPlane.w/detectPlane.y),0)
            }else {
                planePoint = SCNVector3(0,0,Int(detectPlane.w/detectPlane.z))
            }
            
            let ray = sceneView.hitTestRayFromScreenPos(position)
            let crossPoint = planeLineIntersectPoint(planeVector: SCNVector3(detectPlane.x,detectPlane.y,detectPlane.z), planePoint: planePoint, lineVector: ray!.direction, linePoint: ray!.origin)
            if crossPoint != nil {
                return (crossPoint, nil, false)
            }else{
                return (featureCloud.average!, nil, false)
            }
        }
        
        if !featureCloud.isEmpty {
            featureHitTestPosition = featureCloud.average
            highQualityFeatureHitTestResult = true
        } else if !highQualityfeatureHitTestResults.isEmpty {
            featureHitTestPosition = highQualityfeatureHitTestResults.map { (featureHitTestResult) -> SCNVector3 in
                return featureHitTestResult.position
                }.average
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if infinitePlane || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
    
    func planeDetectWithFeatureCloud(featureCloud: [NSValue]) -> SCNVector4 {
        let result = PlaneDetector.detectPlane(withPoints: featureCloud)
        return result
    }
    
    /// 根据直线上的点和向量及平面上的点和法向量计算交点
    ///
    /// - Parameters:
    ///   - planeVector: 平面法向量
    ///   - planePoint: 平面上一点
    ///   - lineVector: 直线向量
    ///   - linePoint: 直线上一点
    /// - Returns: 交点
    func planeLineIntersectPoint(planeVector: SCNVector3 , planePoint: SCNVector3, lineVector: SCNVector3, linePoint: SCNVector3) -> SCNVector3? {
        let vpt = planeVector.x*lineVector.x + planeVector.y*lineVector.y + planeVector.z*lineVector.z
        if vpt != 0 {
            let t = ((planePoint.x-linePoint.x)*planeVector.x + (planePoint.y-linePoint.y)*planeVector.y + (planePoint.z-linePoint.z)*planeVector.z)/vpt
            let cross = SCNVector3Make(linePoint.x + lineVector.x*t, linePoint.y + lineVector.y*t, linePoint.z + lineVector.z*t)
            if (cross-linePoint).length() < 5 {
                return cross
            }
        }
        return nil
    }
}
