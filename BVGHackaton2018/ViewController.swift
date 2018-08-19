//
//  ViewController.swift
//  BVGHackaton2018
//
//  Created by Daniel Montano on 18.08.18.
//  Copyright © 2018 Daniel Montano. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

extension Double {
    var toRadians: Double { return self * .pi / 180 }
    var toDegrees: Double { return self * 180 / .pi }
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // @IBOutlet weak var minimapview: MiniMap!
    var gridSize = 5
    
    @IBOutlet weak var displayLabel: UILabel!
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let kEnterBeacon = Notification.Name("BeaconServiceRegionEnter")
    let kUpdateBeacon = Notification.Name("BeaconServiceRegionUpdate")
    let kExitBeacon = Notification.Name("BeaconServiceRegionExit")
    let kEnterGeofence = Notification.Name("GeofenceServiceRegionEnter")
    let kExitGeofence = Notification.Name("GeofenceServiceRegionExit")
    
    
    var minimap: MiniMap!
    
    
    var message1 = "Du bist am Hauptbahnhof auf Gleis 3 angekommen. \nFolge den grünen Pfeil geradeaus um am Ende des \nGleises anzukommen"
    var message2 = "Biege links ab und folge den \nPfeil bis zur nächsten Ecke"
    var message3 = "Geh durch die Tür nach draußen, \ndu bist am Ziel ;)"
    
    var mes1PosVector = SCNVector3(2.0, -0.8, -3.0)
    var mes2PosVector = SCNVector3(-2.0, -0.8, 2.0)
    var mes3PosVector = SCNVector3(2.0, -0.8, -3.0)
    
    
    
    // Current Position variales
    
    var currentLatitude: Double = 0
    var currentLongitude: Double = 0
    
    var timeReset = 10.0
    
    var deviation = 30.0
    
    var minimapSetupDone: Bool = false
    
    var b1Pos = (1,0)
    var b2Pos = (0,2)
    var b3Pos = (1,4)
    
    var d1: Double?
    var d1LastTime = Date()

    var d2: Double?
    var d2LastTime = Date()
    
    var d3: Double?
    var d3LastTime = Date()
    
    var currentPosition: (Int,Int)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addRegionObserver()
        
        minimap = MiniMap.instantiateFromNib()!
        
        
        let rect = CGRect(origin: CGPoint(x:30, y:50), size: CGSize(width:80, height:100))
        let positionView = UIView(frame: rect)
        positionView.backgroundColor = UIColor.clear
        positionView.addSubview(minimap)
        
        sceneView.addSubview(positionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.delegate = self
        
        setupConfiguration()
        addArrow()
        startTimer()
    }
    
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLatitude = locations[0].coordinate.latitude
        self.currentLongitude = locations[0].coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        UIView.animate(withDuration: 0.5) {
            
            let angle = newHeading.magneticHeading.toRadians // convert from degrees to radians
            // self.minimap.transform = CGAffineTransform(rotationAngle: CGFloat( angle)) // rotate the picture
        }
    }
    
    func timeSinceLastGeneralUpdate() -> Double {
        
        return min(d1LastTime.timeIntervalSinceNow,d2LastTime.timeIntervalSinceNow,d3LastTime.timeIntervalSinceNow)
    }
    
    func calculatePosition(beaconInfos: [Int: Double]) -> (Int, Int)? {
        
        self.currentPosition = nil
        
        let timeDif1d = abs(d1LastTime.timeIntervalSinceNow)
        if(d1 != nil && timeDif1d > timeReset && timeSinceLastGeneralUpdate() < timeReset){
            d1 = nil
            BIBeaconService.initWithToken("ogqqzwFEtqQWTek5Y34W")
        }
        
        let timeDif2d = abs(d2LastTime.timeIntervalSinceNow)
        if(d2 != nil && timeDif2d > timeReset && timeSinceLastGeneralUpdate() < timeReset){
            d2 = nil
            BIBeaconService.initWithToken("ogqqzwFEtqQWTek5Y34W")
        }
        
        let timeDif3d = abs(d3LastTime.timeIntervalSinceNow)
        if(d3 != nil && timeDif3d > timeReset && timeSinceLastGeneralUpdate() < timeReset){
            d3 = nil
            BIBeaconService.initWithToken("ogqqzwFEtqQWTek5Y34W")
        }
        
        for beaconInfo in beaconInfos {
            if (beaconInfo.value != -1){
                
                switch beaconInfo.key {
                case 8:
                    print("Updating Beacon \(beaconInfo.key) with \(beaconInfo.value)")
                    d1 = beaconInfo.value
                    d1LastTime = Date()
                    
                case 1:
                    print("Updating Beacon \(beaconInfo.key) with \(beaconInfo.value)")
                    d2 = beaconInfo.value
                    d2LastTime = Date()
                case 5:
                    print("Updating Beacon \(beaconInfo.key) with \(beaconInfo.value)")
                    d3 = beaconInfo.value
                    d3LastTime = Date()
                default:
                    print("beaconMinor \(beaconInfo.key) mit Accuracy:\(beaconInfo.value) gefunden aber ignoriert!!")
                    return self.currentPosition
                }
            }else{
                return self.currentPosition
            }
        }
        
        // Nur wenn einer da ist
        if(d1 == nil && d2 == nil && d3 != nil ){
            self.currentPosition = b3Pos
        }
        
        if(d1 == nil && d3 == nil && d2 != nil){
            self.currentPosition = b2Pos
        }
        
        if(d2 == nil && d3 == nil && d1 != nil){
            self.currentPosition = b1Pos
        }
        
        if let currentPosition = currentPosition {
            return currentPosition
        }else{
            
            if (d1 != nil && d2 != nil && d3 == nil){
                if (d1! < d2!) {
                    self.currentPosition = b1Pos
                }else{
                    self.currentPosition = b2Pos
                }
            }
            
            if (d1 != nil && d3 != nil && d2 == nil){
                if (d1! < d3!) {
                    self.currentPosition = b1Pos
                }else{
                    self.currentPosition = b3Pos
                }
            }
            
            if (d2 != nil && d3 != nil && d1 == nil){
                if (d2! < d3!) {
                    self.currentPosition = b2Pos
                }else{
                    self.currentPosition = b3Pos
                }
            }
            
            if let currentPosition = currentPosition {
                return currentPosition
            }else{
                
                // Es sind alle 3!!!
                
                if(d1! < d2! && d1! < d3!){
                    self.currentPosition = b1Pos
                }
                
                if(d2! < d3! && d2! < d1!){
                    self.currentPosition = b2Pos
                }
                
                if(d3! < d1! && d3! < d2!){
                    self.currentPosition = b3Pos
                }
                
                return self.currentPosition!
                
            }
        }
    }
    
    
    func addArrow() {
        
        if(self.currentPosition != nil){
            
            var arrow: Arrow?
            
            if(self.currentPosition!.0 == 1 && self.currentPosition!.1 == 4){
                arrow = Arrow()
                arrow!.loadModel(n:1)
                arrow!.position = mes1PosVector
                self.displayLabel.text = message1
                arrow!.rotation = SCNVector4Zero
                //let action = SCNAction.rotateBy(x: 0, y: CGFloat(310.0 * Double.pi), z: 0, duration: 0.1)
                //arrow.runAction(action, forKey: "myrotate")
            }
            if(self.currentPosition!.0 == 0 && self.currentPosition!.1 == 2){
                arrow = Arrow()
                arrow!.loadModel(n:2)
                arrow!.position = mes2PosVector
                arrow!.rotation = SCNVector4Zero
                self.displayLabel.text = message2
            }
            if(self.currentPosition!.0 == 1 && self.currentPosition!.1 == 0){
                arrow = Arrow()
                arrow!.loadModel(n:3)
                arrow!.position = mes3PosVector
                arrow!.rotation = SCNVector4Zero
                self.displayLabel.text = message3
            }
            
            
            let flourPlane = SCNFloor()
            let groundPlane = SCNNode()
            let groundMaterial = SCNMaterial()
            groundMaterial.lightingModel = .constant
            groundMaterial.writesToDepthBuffer = true
            groundMaterial.colorBufferWriteMask = []
            groundMaterial.isDoubleSided = true
            flourPlane.materials = [groundMaterial]
            groundPlane.geometry = flourPlane
            //
            arrow!.addChildNode(groundPlane)
            // Create a ambient light
            let ambientLight = SCNNode()
            ambientLight.light = SCNLight()
            ambientLight.light?.shadowMode = .deferred
            ambientLight.light?.color = UIColor.white
            ambientLight.light?.type = SCNLight.LightType.ambient
            ambientLight.position = SCNVector3(x: 0,y: 5,z: 0)
            // Create a directional light node with shadow
            let myNode = SCNNode()
            myNode.light = SCNLight()
            myNode.light?.type = SCNLight.LightType.directional
            myNode.light?.color = UIColor.white
            myNode.light?.castsShadow = true
            myNode.light?.automaticallyAdjustsShadowProjection = true
            myNode.light?.shadowSampleCount = 64
            myNode.light?.shadowRadius = 16
            myNode.light?.shadowMode = .deferred
            myNode.light?.shadowMapSize = CGSize(width: 2048, height: 2048)
            myNode.light?.shadowColor = UIColor.black.withAlphaComponent(0.75)
            myNode.position = SCNVector3(x: 0,y: 5,z: 0)
            myNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            // Add the lights to the container
            arrow!.addChildNode(ambientLight)
            arrow!.addChildNode(myNode)
            
            if(self.currentPosition != nil){
                sceneView.scene.rootNode.addChildNode(arrow!)
            }
            
        }else{
            //self.displayLabel.text = "Hallo!"
           // arrow.position = mes1PosVector
            //arrow.rotation = SCNVector4Zero
        }
        
    }
    
    func startTimer(){
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
            BIBeaconService.initWithToken("ogqqzwFEtqQWTek5Y34W")
            self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                print("node!")
                node.removeFromParentNode()
            }
            self.sceneView.session.run(self.configuration, options: [.resetTracking,.removeExistingAnchors])
            let localConfig = ARWorldTrackingConfiguration()
            
            localConfig.worldAlignment = .gravityAndHeading
            self.sceneView.session.run(localConfig)
            
//            let arrow = Arrow()
//            arrow.loadModel()
//            arrow.position = self.kStartingPosition
//            arrow.rotation = SCNVector4Zero
//            self.sceneView.scene.rootNode.addChildNode(arrow)
            
            self.addArrow()

            print("reloading")
        })
    }
    
    // MARK: - setup
    func setupScene() {
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    func setupConfiguration() {
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
        
    }
    
    func getArrowVectorAndRotation () -> (SCNVector3, SCNVector4){
        
        return (SCNVector3Zero, SCNVector4Zero)
    }
    
    func addRegionObserver() {
        
        for name in [kEnterBeacon,kUpdateBeacon,kExitBeacon,kEnterGeofence,kExitGeofence] {
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didReceiveNotification(notification:)), name: name, object: nil)
        }
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        
        // print("userInfo: %@", notification.userInfo!)
        if let userInfo = notification.userInfo {
            let hackathonUUID = userInfo["uuid"] as? String
            
            if let uuidStr = hackathonUUID {
                if(uuidStr == "F7826DA6-4FA2-4E98-8024-BC5B71E0893E"){
                    
                    let minor = userInfo["minor"] as! Int
                    let accuracy = userInfo["accuracy"] as! Double
                    
                    //print("This is the Accuracy: %@", accuracy) // Int
                    //print("This is the Minor: %@", minor) // Int
                    
                    //self.minimap.redraw(squares: [(0,0)])
                    
                    if(!self.minimapSetupDone){
                        self.minimap.setup()
                        self.minimapSetupDone = true
                    }
                    
                    
                    
                    var newPos = calculatePosition(beaconInfos: [minor:accuracy])
                    
                    if let cPos = self.currentPosition, let uNewPos = newPos {
                        
                        if(cPos == uNewPos){
                            APIManager.sharedInstance.sendCoords(latitude: self.currentLatitude, longitude: self.currentLongitude, callback: { error in
                                if let error = error {
                                    print(error)
                                }
                            })
                        }
                    }
                    
                    
                    self.currentPosition = newPos
                    
                    if let currentPosition = self.currentPosition {
                        self.minimap.redraw(squares: [currentPosition])
                    }
                }
            }
           
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

