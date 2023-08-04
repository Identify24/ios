//
//  SDKLivenessViewController.swift
//  NewTest
//
//  Created by Emir Beytekin on 14.11.2022.
//

import UIKit
import SceneKit
import ARKit
import IdentifySDK

class SDKLivenessViewController: SDKBaseViewController {

    @IBOutlet weak var resetCamBtn: IdentifyButton!
    @IBOutlet weak var myCam: ARSCNView!
    let configuration = ARFaceTrackingConfiguration()
    @IBOutlet weak var pauseView: UIView!
    
    private var lookCamTxt: String {
        return languageManager.translate(key: .livenessLookCam)
    }
    
    private var blinkEyeTxt: String {
        return languageManager.translate(key: .livenessStep2)
    }
    
    private var headLeftTxt: String {
        return languageManager.translate(key: .livenessStep4)
    }
    
    private var headRightTxt: String {
        return languageManager.translate(key: .livenessStep3)
    }
    
    private var smileTxt: String {
        return languageManager.translate(key: .livenessStep1)
    }
    
    @IBOutlet weak var stepInfoLbl: UILabel!
    var nextStep: LivenessTestStep?
    var takenPhotoCount = 0
    var totalStepsCount = 4
    var currentLivenessType: OCRType? = .selfie
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.totalStepsCount = (self.manager.livenessRandomOrder?.count ?? 4)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pauseSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if nextStep == nil {
            self.getNextTest()
        } else if nextStep == .completed {
            self.pauseSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.showToast(type: .success, title: self.translate(text: .coreSuccess), subTitle: "Bu modül zaten tamamlandı", attachTo: self.view) {
                    self.manager.getNextModule { nextVC in
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                }
            })
        }
        self.resumeSession()
    }
    
    override func appMovedToBackground() {
        self.pauseSession()
    }
    
    override func appMovedToForeground() {
        self.pauseView.isHidden = false
    }
    
    private func appendInfoText(_ text: String?) {
        DispatchQueue.main.async {
            self.stepInfoLbl.text = text
        }
    }
    
    private func pauseSession() {
        if self.takenPhotoCount == self.totalStepsCount + 1 {
            self.killArSession()
        } else {
            DispatchQueue.main.async {
                self.myCam.session.pause()
            }
        }
    }
    
    private func resumeSession() {
        if self.takenPhotoCount == self.totalStepsCount + 1 {
            self.killArSession()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.myCam.session.run(self.configuration)
                self.hideLoader()
            })
        }
    }
    
    private func killArSession() {
        myCam?.session.pause()
        myCam?.removeFromSuperview()
        myCam = nil
    }
    
    private func setupUI() {
        myCam.delegate = self
        self.getNextTest()
        if ARFaceTrackingConfiguration.isSupported {
            self.resumeSession()
        } else {
            self.showToast(type:.fail, title: self.translate(text: .coreError), subTitle: "Cihazınız ARFace Desteklemiyor", attachTo: self.view) {
                self.skipModuleAct()
            }
        }
        self.resetCamBtn.onTap = {
            if self.nextStep == nil {
                self.getNextTest()
            }
            self.pauseView.isHidden = true
            self.resumeSession()
        }
        self.appendInfoText(self.lookCamTxt)
        self.resetCamBtn.type = .info
        self.resetCamBtn.populate()
    }
    
    private func getNextTest() {
        manager.getNextLivenessTest { nextStep, completed in
            self.nextStep = nextStep
            if completed ?? false {
                self.pauseSession()
                DispatchQueue.main.async {
                    if self.takenPhotoCount == self.totalStepsCount + 1 {
                        self.manager.getNextModule { nextVC in
                            self.navigationController?.pushViewController(nextVC, animated: true)
//                            self.takenPhotoCount = 0
                            self.nextStep = .completed
                        }
                    }
                }
            }
        }
    }
    
    private func sendScreenShot(uploaded: @escaping(Bool) -> ()) {
        let image = myCam.snapshot()
        DispatchQueue.main.async {
            self.showLoader()
        }
        manager.uploadIdPhoto(idPhoto: image, selfieType: self.currentLivenessType ?? .signature) { uploadResp in
            self.takenPhotoCount += 1
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            if uploadResp.result == true {
                uploaded(true)
                self.resumeSession()
                return
            } else {
                DispatchQueue.main.async {
                    self.showToast(type:.fail, title: self.translate(text: .coreError), subTitle: self.translate(text: .coreUploadError), attachTo: self.view) {
                        uploaded(false)
                        self.resumeSession()
                        return
                    }
                }
            }
            
        }
    }
}

extension SDKLivenessViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: myCam.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor, node: node)
        }
    }
    
    func checkTurnLeft(jawVal:Decimal) {
        appendInfoText(self.headLeftTxt)
        self.currentLivenessType = .headToLeft
        if abs(jawVal) > 0.15 {
            self.pauseSession()
            sendScreenShot(uploaded: { resp in
                self.getNextTest()
            })
            return
        }
    }
    
    func checkTurnRight(jawVal:Decimal) {
        appendInfoText(self.headRightTxt)
        self.currentLivenessType = .headToRight
        if abs(jawVal) > 0.15 {
            self.pauseSession()
            sendScreenShot(uploaded: { resp in
                self.getNextTest()
            })
            return
        }
    }
    
    func blinkEyes(leftEye: Decimal, rightEye: Decimal) {
        appendInfoText(self.blinkEyeTxt)
        self.currentLivenessType = .blinking
        if abs(leftEye) > 0.35 && abs(rightEye) > 0.35 {
            self.pauseSession()
            sendScreenShot(uploaded: { resp in
                self.getNextTest()
            })
            return
        }
    }
    
    func detectSmile(smileLeft: Decimal, smileRight: Decimal) {
        appendInfoText(self.smileTxt)
        self.currentLivenessType = .smiling
        if smileLeft + smileRight > 0.9 {
            self.pauseSession()
            sendScreenShot(uploaded: { resp in
                self.getNextTest()
            })
            return
        }
    }
    
    func expression(anchor: ARFaceAnchor, node: SCNNode) {
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]?.decimalValue
        let smileRight = anchor.blendShapes[.mouthSmileRight]?.decimalValue
        let jawLeft = anchor.blendShapes[.jawLeft]?.decimalValue
        let jawRight = anchor.blendShapes[.jawRight]?.decimalValue
        let leftEyeOpen = anchor.blendShapes[.eyeBlinkLeft]?.decimalValue
        let rightEyeOpen = anchor.blendShapes[.eyeBlinkRight]?.decimalValue
        
        switch self.nextStep {
            case .turnLeft:
                self.checkTurnLeft(jawVal: jawLeft ?? 0)
                break
            case .turnRight:
                self.checkTurnRight(jawVal: jawRight ?? 0)
                break
            case .smile:
                self.detectSmile(smileLeft: smileLeft ?? 0, smileRight: smileRight ?? 0)
                break
            case .blinkEyes:
                self.blinkEyes(leftEye: leftEyeOpen ?? 0, rightEye: rightEyeOpen ?? 0)
                break
            default:
                return
        }
    }
    
}
