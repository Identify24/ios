//
//  SDKCallScreenViewController.swift
//  NewTest
//
//  Created by Emir Beytekin on 15.11.2022.
//

import UIKit
import IdentifySDK
import CHIOTPField

protocol CallScreenDelegate: AnyObject {
    func acceptCall()
}

class SDKCallScreenViewController: SDKBaseViewController {

    @IBOutlet weak var plsWaitLbl: UILabel!
    @IBOutlet weak var smsLblDesc: UILabel!
    @IBOutlet weak var waitDesc1: UILabel!
    @IBOutlet weak var waitDesc2: UILabel!
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var waitScreen: UIView!
    @IBOutlet weak var customerCam: UIView!
    @IBOutlet weak var myCam: UIView!
    @IBOutlet weak var callScreen: UIView!
    @IBOutlet weak var qualityImg: UIImageView! // bağlantı kalitesi imajı
    @IBOutlet weak var smsStackView: UIView!
    @IBOutlet weak var timeInfoLbl: UILabel!
    private var confStarted = false // ilk kez bağlantı kurulma - temsilci ve kişinin kamerasını bu değişkene göre aktif eder

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
        setupCallScreen(inCall: false)
        self.manager.socketMessageListener = self
        if manager.connectToSignLang {
            self.checkSignLang()
        }
        navigationItem.rightBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.confStarted = false
    }
    
    private func setupUI() {
        UIApplication.shared.isIdleTimerDisabled = true // görüşürken veya beklerken ekran kapanmaması için
        self.waitDesc1.text = self.translate(text: .waitingDesc1)
        self.waitDesc2.text = self.translate(text: .waitingDesc2)
        self.smsLblDesc.text = self.translate(text: .enterSmsCode)
        self.plsWaitLbl.text = self.translate(text: .corePlsWait)
        
    }
    
    private func checkSignLang() {
        let signVC = SDKSignLangViewController()
        signVC.isModalInPresentation = true
        self.present(signVC, animated: true)
    }
    
    private func setupCallScreen(inCall: Bool) { // bekleme ekranı veya aktif görüşme ekranı arasındaki geçişi sağlar
        DispatchQueue.main.async {
            self.waitScreen.isHidden = inCall
            self.callScreen.isHidden = !inCall
            if inCall {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
        }
    }
    
    private func setupMyCamera() { // kendi kameramızı ayarlar
        let localVideoView = manager.webRTCClient.localVideoView()
        localVideoView.tag = 100
        manager.webRTCClient.setupLocalViewFrame(frame: CGRect(x: 0, y: 0, width: self.myCam.frame.width, height: self.myCam.frame.height))
        self.myCam.addSubview(localVideoView)
        self.myCam.bringSubviewToFront(self.qualityImg)
    }
    
    private func setupCustomerCamera() { // temsilcimizin görüntüsünü ayarlar
        let remoteVideoView = manager.webRTCClient.remoteVideoView()
        manager.webRTCClient.setupRemoteViewFrame(frame: CGRect(x: 0, y: 0, width: customerCam.frame.width, height: customerCam.frame.height))
        remoteVideoView.roundCorners(corners: .allCorners, radius: 12)
        self.customerCam.addSubview(remoteVideoView)
        manager.webRTCClient.calculateLocalSize()
        self.setupCallScreen(inCall: true)
    }
    
    private func start2SideTransfer() {
        DispatchQueue.main.async {
            self.setupMyCamera()
            self.setupCustomerCamera()
            self.hideLoader()
        }
    }
    
}

extension SDKCallScreenViewController: CallScreenDelegate {
    
    func acceptCall() { // temsilciden gelen  çağrı kabul edilince bu fonksiyon çalışır
        manager.acceptCall { connected, errMsg, sdpHaveErr in
            if let _ = connected, !connected! {
                self.showToast(title: self.translate(text: .coreError), subTitle: errMsg?.errorMessages ?? "", attachTo: self.view) {
                    return
                }
            } else {
                if sdpHaveErr! { // sdp bağlantısı kuruldu
                    DispatchQueue.main.async {
                        self.showLoader()
                    }
                }
            }
        }
    }
}

extension SDKCallScreenViewController: SDKSocketListener {
    
    func listenSocketMessage(message: SDKCallActions) {
        print("comin action: \(message)")
        switch message {
            case .incomingCall:
                print("yeni bir çağrı geliyor")
                let nextVC = SDKRingViewController()
                nextVC.delegate = self
                self.present(nextVC, animated:true)
            case .comingSms:
                self.openSMS()
                print("sms geliyor")
            case .endCall:
                manager.socket.disconnect()
                print("görüşme tamamlandı, sonraki modüle geçebiliriz")
            case .approveSms(let tanCode):
                print("sms onaylandı :\(tanCode)")
            case .openWarningCircle:
                print("surat çerçevesi açıldı")
            case .closeWarningCircle:
                print("surat çerçevesi kapatıldı")
            case .openCardCircle:
                print("kart çerçevesi açıldı")
            case .closeCardCircle:
                print("kart çerçevesi kapatıldı")
            case .terminateCall:
                self.listenToSocketConnection(callCompleted: true)
//                manager.socket.disconnect()
                setupCallScreen(inCall: false)
                self.manager.getNextModule { nextVC in
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
                print("görüşme kapandı")
            case .imOffline:
                print("bağlantı kopartıldı - panelde sayfa yenilendi - browser kapatıldı")
                confStarted = false
                setupCallScreen(inCall: false)
            case .updateQueue(let order, let min):
                self.timeInfoLbl.text = "\(self.translate(text: .waitingDesc1Live))\(order)\(self.translate(text: .waitingDesc2Live))\(min)\(self.translate(text: .waitingDesc3Live))"
            case .photoTaken(let msg):
                print("temsilci ekran fotoğrafı çekti \(msg)")
                self.showToast(title: msg, subTitle: "", attachTo: self.view) {
                    return
                }
            case .subrejectedDismiss:
                print("aynı odada başka kişi var")
            case .subscribed:
                print("odaya katılım sağlandı")
            case .openNfcRemote(let birthDate, let validDate, let serialNo):
                manager.startRemoteNFC(birthDate: birthDate, validDate: validDate, docNo: serialNo)
                print("uzaktan nfc başlatıldı")
            case .startTransfer:
                self.showToast(title: "Kameranız ayarlanıyor, lütfen bekleyin", attachTo: self.view) {
                    self.start2SideTransfer()
                    return
                }
                print("yüz yüze görüşme başlıyor")
            case .networkQuality(let quality):
                print("bağlantı kalitesine göre sinyal resmi basılıyor")
                switch quality {
                    case "bad":
                        DispatchQueue.main.async {
                            self.qualityImg.image = UIImage(named: "badConn")
                        }
                    case "medium":
                        DispatchQueue.main.async {
                            self.qualityImg.image = UIImage(named: "mediumConn")
                        }
                    case "good":
                        DispatchQueue.main.async {
                            self.qualityImg.image = UIImage(named: "goodConn")
                        }
                    default:
                        DispatchQueue.main.async {
                            self.qualityImg.image = UIImage()
                        }
                }
            @unknown default:
                return
            }
    }
}


extension SDKCallScreenViewController {
    
    func openSMS() {
        codeTxt.becomeFirstResponder()
        codeTxt.delegate = self
        codeTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.smsStackView.isHidden = false
    }
    
    func resetSMSInput(endEditing:Bool? = false) {
        DispatchQueue.main.async {
            if endEditing! {
                self.view.endEditing(true)
            } else {
                self.codeTxt.becomeFirstResponder()
            }
            self.codeTxt.text = .none
            self.codeTxt.text = String(repeating: " ", count: 6)
            self.codeTxt.text = ""
        }
    }
    
}

extension SDKCallScreenViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 6 {
            showLoader()
            manager.smsVerification(tan: codeTxt.text!) { resp in
                self.hideLoader()
                self.smsStackView.isHidden = resp
                if resp == false {
                    self.showToast(title: self.translate(text: .coreError), subTitle: self.translate(text: .wrongSMSCode), attachTo: self.view) {
                        self.resetSMSInput(endEditing:false)
                    }
                } else {
                    self.resetSMSInput(endEditing: true)
                }
            }
        }
    }
    
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
