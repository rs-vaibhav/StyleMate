import SwiftUI
import SceneKit

// Human body as extruded silhouette path — much cleaner than lofted circles
class BodySceneBuilder {
    static func buildScene(
        skinTone: SkinTone, gender: Gender, bodyType: BodyType,
        topImage: UIImage?=nil, bottomImage: UIImage?=nil, footwearImage: UIImage?=nil,
        topColor: Color?=nil, bottomColor: Color?=nil, footwearColor: Color?=nil, accessoryColor: Color?=nil
    ) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red:0.94,green:0.95,blue:0.97,alpha:1)
        
        let p = dims(bodyType, gender)
        let skin = skinC(skinTone)
        let root = SCNNode()
        
        // Floor
        let fl = SCNFloor(); fl.reflectivity = 0.04
        fl.firstMaterial?.diffuse.contents = UIColor(white:0.88,alpha:1)
        fl.firstMaterial?.lightingModel = .physicallyBased
        let fln = SCNNode(geometry:fl); fln.position = SCNVector3(0,-1.0,0)
        scene.rootNode.addChildNode(fln)
        
        // === HEAD (3D sphere) ===
        let head = SCNSphere(radius: CGFloat(p.headR))
        head.segmentCount = 32
        head.firstMaterial = mkSkin(skin)
        let headN = SCNNode(geometry:head)
        headN.position = SCNVector3(0, 0.78, 0)
        root.addChildNode(headN)
        
        // Hair
        let hair = SCNSphere(radius: CGFloat(p.headR * 1.06))
        hair.segmentCount = 32
        hair.firstMaterial = mkCloth(UIColor(red:0.12,green:0.08,blue:0.05,alpha:1))
        let hairN = SCNNode(geometry:hair)
        hairN.position = SCNVector3(0, 0.03, -0.01)
        hairN.scale = SCNVector3(1, 0.55, 0.95)
        headN.addChildNode(hairN)
        
        // Eyes
        for s: Float in [-1,1] {
            let eye = SCNSphere(radius:0.014); eye.segmentCount=16
            eye.firstMaterial={let m=SCNMaterial();m.diffuse.contents=UIColor.white;m.lightingModel = .physicallyBased;return m}()
            let en=SCNNode(geometry:eye); en.position=SCNVector3(s*0.032, 0.01, Float(p.headR)*0.9)
            headN.addChildNode(en)
            let ir=SCNSphere(radius:0.007); ir.segmentCount=12
            ir.firstMaterial={let m=SCNMaterial();m.diffuse.contents=UIColor(red:0.18,green:0.10,blue:0.05,alpha:1);m.lightingModel = .physicallyBased;return m}()
            let irn=SCNNode(geometry:ir); irn.position=SCNVector3(0,0,0.009); en.addChildNode(irn)
        }
        // Mouth
        let lip=SCNCapsule(capRadius:0.005,height:0.02); lip.firstMaterial=mkCloth(UIColor(red:0.68,green:0.35,blue:0.35,alpha:1))
        let ln=SCNNode(geometry:lip); ln.position=SCNVector3(0,-0.03,Float(p.headR)*0.88)
        ln.eulerAngles=SCNVector3(0,0,Float.pi/2); headN.addChildNode(ln)
        
        // Neck
        let neck = SCNCylinder(radius: CGFloat(p.headR*0.45), height: 0.08)
        neck.radialSegmentCount = 20
        neck.firstMaterial = mkSkin(skin)
        let neckN = SCNNode(geometry:neck); neckN.position = SCNVector3(0, 0.66, 0)
        root.addChildNode(neckN)
        
        // === TORSO — front panel with clothing texture ===
        let torsoW = p.shoulderW * 2
        let torsoH: Float = 0.58
        let torsoD: Float = 0.16
        
        // Front face — shows clothing photo
        let frontGeo = SCNPlane(width: CGFloat(torsoW), height: CGFloat(torsoH))
        frontGeo.cornerRadius = CGFloat(torsoW * 0.08)
        if let img = topImage {
            frontGeo.firstMaterial = mkTexture(img)
        } else {
            let tc = topColor != nil ? UIColor(topColor!) : UIColor(red:0.25,green:0.42,blue:0.82,alpha:1)
            frontGeo.firstMaterial = mkCloth(tc)
        }
        let frontN = SCNNode(geometry:frontGeo)
        frontN.position = SCNVector3(0, 0.34, CGFloat(torsoD/2 + 0.001))
        root.addChildNode(frontN)
        
        // Back face
        let backGeo = SCNPlane(width: CGFloat(torsoW), height: CGFloat(torsoH))
        backGeo.cornerRadius = CGFloat(torsoW * 0.08)
        let backColor = topColor != nil ? UIColor(topColor!) : UIColor(red:0.22,green:0.38,blue:0.75,alpha:1)
        backGeo.firstMaterial = mkCloth(backColor)
        let backN = SCNNode(geometry:backGeo)
        backN.position = SCNVector3(0, 0.34, CGFloat(-torsoD/2 - 0.001))
        backN.eulerAngles = SCNVector3(0, Float.pi, 0)
        root.addChildNode(backN)
        
        // Side panels
        let sideGeo = SCNBox(width: CGFloat(torsoW), height: CGFloat(torsoH), length: CGFloat(torsoD), chamferRadius: CGFloat(torsoD*0.3))
        let sideMat = topColor != nil ? mkCloth(UIColor(topColor!)) : mkCloth(UIColor(red:0.22,green:0.38,blue:0.75,alpha:1))
        sideGeo.firstMaterial = sideMat
        let sideN = SCNNode(geometry:sideGeo)
        sideN.position = SCNVector3(0, 0.34, 0)
        root.addChildNode(sideN)
        
        // Move front/back to render on top of box
        frontN.renderingOrder = 1
        backN.renderingOrder = 1
        
        // === ARMS ===
        for s: Float in [-1,1] {
            let sx = s * (p.shoulderW + 0.02)
            // Shoulder sphere
            let sh = SCNSphere(radius: CGFloat(p.armR*1.6)); sh.segmentCount=16
            sh.firstMaterial = sideMat
            let shn = SCNNode(geometry:sh); shn.position=SCNVector3(sx, 0.56, 0)
            root.addChildNode(shn)
            // Upper arm (sleeve)
            let ua = SCNCapsule(capRadius: CGFloat(p.armR*1.1), height: CGFloat(0.22))
            ua.radialSegmentCount=14
            ua.firstMaterial = sideMat
            let uan = SCNNode(geometry:ua); uan.position=SCNVector3(sx, 0.40, 0)
            root.addChildNode(uan)
            // Forearm (skin)
            let fa = SCNCapsule(capRadius: CGFloat(p.armR*0.9), height: CGFloat(0.22))
            fa.radialSegmentCount=14
            fa.firstMaterial = mkSkin(skin)
            let fan = SCNNode(geometry:fa); fan.position=SCNVector3(sx+s*0.008, 0.18, 0)
            root.addChildNode(fan)
            // Hand
            let hand = SCNSphere(radius: CGFloat(p.armR*1.0)); hand.segmentCount=12
            hand.firstMaterial = mkSkin(skin)
            let hn = SCNNode(geometry:hand)
            hn.position=SCNVector3(sx+s*0.012, 0.06, 0)
            hn.scale=SCNVector3(0.8,1.15,0.55); root.addChildNode(hn)
        }
        
        // === LEGS ===
        let legY: Float = 0.05  // torso bottom
        for s: Float in [-1, 1] {
            let lx = s * p.shoulderW * 0.42
            
            // Thigh — front panel with texture
            let thighH: Float = 0.38
            let thighW: Float = p.legR * 2.4
            let thighD: Float = p.legR * 2.0
            
            // Thigh 3D body
            let thBox = SCNBox(width:CGFloat(thighW), height:CGFloat(thighH), length:CGFloat(thighD), chamferRadius:CGFloat(thighD*0.4))
            if let img = bottomImage {
                thBox.firstMaterial = mkTexture(img)
            } else {
                let bc: UIColor = bottomColor != nil ? UIColor(bottomColor!) : UIColor(red:0.12,green:0.12,blue:0.28,alpha:1)
                thBox.firstMaterial = mkCloth(bc)
            }
            let thN = SCNNode(geometry:thBox)
            thN.position = SCNVector3(lx, legY - thighH/2 - 0.01, 0)
            root.addChildNode(thN)
            
            // Calf
            let calfH: Float = 0.36
            let calfW: Float = p.legR * 2.0
            let calfD: Float = p.legR * 1.7
            let caBox = SCNBox(width:CGFloat(calfW), height:CGFloat(calfH), length:CGFloat(calfD), chamferRadius:CGFloat(calfD*0.4))
            if let img = bottomImage {
                caBox.firstMaterial = mkTexture(img)
            } else {
                let bc: UIColor = bottomColor != nil ? UIColor(bottomColor!) : UIColor(red:0.12,green:0.12,blue:0.28,alpha:1)
                caBox.firstMaterial = mkCloth(bc)
            }
            let caN = SCNNode(geometry:caBox)
            caN.position = SCNVector3(lx, legY - thighH - calfH/2 - 0.02, 0)
            root.addChildNode(caN)
            
            // Shoe
            let shoeH: Float = 0.06
            let shoeGeo = SCNBox(width:CGFloat(calfW*1.1), height:CGFloat(shoeH), length:CGFloat(calfD*1.8), chamferRadius:CGFloat(shoeH*0.4))
            if let img = footwearImage {
                shoeGeo.firstMaterial = mkTexture(img)
            } else {
                let fc: UIColor = footwearColor != nil ? UIColor(footwearColor!) : UIColor(red:0.1,green:0.1,blue:0.1,alpha:1)
                shoeGeo.firstMaterial = mkCloth(fc)
            }
            let shN = SCNNode(geometry:shoeGeo)
            let shoeY: Float = legY - thighH - calfH - shoeH/2 - 0.03
            shN.position = SCNVector3(lx, shoeY, calfD*0.3)
            root.addChildNode(shN)
        }
        
        // Belt
        if let ac = accessoryColor {
            let belt = SCNBox(width:CGFloat(torsoW+0.01), height:0.025, length:CGFloat(torsoD+0.01), chamferRadius:0.008)
            belt.firstMaterial = mkCloth(UIColor(ac))
            let bn = SCNNode(geometry:belt); bn.position=SCNVector3(0,legY+0.01,0)
            bn.renderingOrder = 2; root.addChildNode(bn)
        }
        
        scene.rootNode.addChildNode(root)
        
        // Lights
        addLights(scene)
        
        // Camera
        let cam = SCNNode(); cam.camera = SCNCamera()
        cam.camera?.fieldOfView = 28; cam.camera?.wantsHDR = true
        cam.position = SCNVector3(0, 0.22, 4.0)
        cam.look(at: SCNVector3(0, 0.15, 0))
        scene.rootNode.addChildNode(cam)
        
        return scene
    }
    
    struct D { var headR:Float; var shoulderW:Float; var armR:Float; var legR:Float }
    private static func dims(_ bt:BodyType, _ g:Gender) -> D {
        var d = D(headR:0.09, shoulderW:0.20, armR:0.038, legR:0.065)
        if g == .female { d.shoulderW*=0.88; d.armR*=0.85; d.legR*=0.95 }
        switch bt {
        case .slim: d.shoulderW*=0.9; d.armR*=0.85; d.legR*=0.88
        case .athletic: d.shoulderW*=1.1; d.armR*=1.15; d.legR*=1.05
        case .average: break
        case .heavy: d.shoulderW*=1.1; d.armR*=1.1; d.legR*=1.15
        }
        return d
    }
    
    private static func mkTexture(_ img:UIImage) -> SCNMaterial {
        let m=SCNMaterial(); m.diffuse.contents=img
        m.diffuse.wrapS = .clamp; m.diffuse.wrapT = .clamp
        m.roughness.contents=NSNumber(value:0.7)
        m.metalness.contents=NSNumber(value:0.0)
        m.lightingModel = .physicallyBased; m.isDoubleSided = true; return m
    }
    private static func mkSkin(_ c:UIColor) -> SCNMaterial {
        let m=SCNMaterial();m.diffuse.contents=c;m.roughness.contents=NSNumber(value:0.72)
        m.metalness.contents=NSNumber(value:0.0);m.lightingModel = .physicallyBased;return m
    }
    private static func mkCloth(_ c:UIColor) -> SCNMaterial {
        let m=SCNMaterial();m.diffuse.contents=c;m.roughness.contents=NSNumber(value:0.7)
        m.metalness.contents=NSNumber(value:0.0);m.lightingModel = .physicallyBased;m.isDoubleSided=true;return m
    }
    private static func skinC(_ t:SkinTone) -> UIColor {
        switch t {
        case .light: return UIColor(red:0.97,green:0.85,blue:0.74,alpha:1)
        case .medium: return UIColor(red:0.84,green:0.69,blue:0.51,alpha:1)
        case .tan: return UIColor(red:0.71,green:0.53,blue:0.34,alpha:1)
        case .dark: return UIColor(red:0.43,green:0.28,blue:0.16,alpha:1)
        }
    }
    private static func addLights(_ sc:SCNScene) {
        let k=SCNLight();k.type = .directional;k.intensity=950
        k.color=UIColor(red:1,green:0.97,blue:0.94,alpha:1)
        k.castsShadow=true;k.shadowRadius=8;k.shadowSampleCount=16
        k.shadowColor=UIColor(white:0,alpha:0.15)
        let kn=SCNNode();kn.light=k;kn.eulerAngles=SCNVector3(-Float.pi/3.5,Float.pi/5,0)
        sc.rootNode.addChildNode(kn)
        let f=SCNLight();f.type = .directional;f.intensity=400
        f.color=UIColor(red:0.85,green:0.90,blue:1,alpha:1)
        let fn=SCNNode();fn.light=f;fn.eulerAngles=SCNVector3(-Float.pi/5,-Float.pi/3,0)
        sc.rootNode.addChildNode(fn)
        let r=SCNLight();r.type = .directional;r.intensity=250
        let rn=SCNNode();rn.light=r;rn.eulerAngles=SCNVector3(-Float.pi/6,Float.pi,0)
        sc.rootNode.addChildNode(rn)
        let a=SCNLight();a.type = .ambient;a.intensity=550;a.color=UIColor(white:0.93,alpha:1)
        sc.rootNode.addChildNode(SCNNode().apply{$0.light=a})
    }
}

private extension SCNNode { func apply(_ f:(SCNNode)->Void) -> SCNNode { f(self); return self } }

struct Avatar3DSceneView: UIViewRepresentable {
    var scene: SCNScene
    func makeUIView(context: Context) -> SCNView {
        let v=SCNView();v.scene=scene;v.backgroundColor = .clear;v.allowsCameraControl=true
        v.autoenablesDefaultLighting=false;v.antialiasingMode = .multisampling4X
        v.defaultCameraController.interactionMode = .orbitTurntable
        v.defaultCameraController.inertiaEnabled=true
        v.defaultCameraController.maximumVerticalAngle=60
        v.defaultCameraController.minimumVerticalAngle = -20; return v
    }
    func updateUIView(_ v:SCNView, context:Context){v.scene=scene}
}
