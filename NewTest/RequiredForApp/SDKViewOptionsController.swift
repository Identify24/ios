//
//  BaseViewController.swift
//  NewTest
//
//  Created by Emir Beytekin on 25.10.2022.
//

import Foundation
import UIKit
import IdentifySDK
import Toast

class SDKViewOptionsController: UIViewController {
    
    let manager = IdentifyManager.shared
    let languageManager = SDKLangManager.shared
    var onTap: VoidHandler?
    public typealias VoidHandler = () -> Void
    var isAlreadyShowingReConnectScreen = false // eğer socket bağlantısı koptuysa zaten reconnect ekranının açık & kapalı durumunu gösterir
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad: \(self)")
        self.addSkipModuleButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBackPhoto(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addBackPhoto(view: self.view)
    }
    
    func addSkipModuleButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip Module", style: .plain, target: self, action: #selector(skipModuleAct))
    }
    
    @objc func skipModuleAct() {
        self.manager.getNextModule { nextMod in
            self.navigationController?.pushViewController(nextMod, animated: true)
        }
    }
    
    func listenToSocketConnection(callCompleted: Bool) {
        if self.manager.socket.isConnected == false {
            self.openSocketDisconnect(callCompleted: callCompleted)
        } else {
            manager.socket.onDisconnect = { [weak self] errMsg in
                guard let self = self else { return }
                self.openSocketDisconnect(callCompleted: callCompleted)
            }
        }
    }
    
    func openSocketDisconnect(callCompleted: Bool) {
        if callCompleted == false && isAlreadyShowingReConnectScreen == false {
            let nextVC = SDKListenSocketViewController()
            nextVC.delegate = self
            isAlreadyShowingReConnectScreen = true
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.modalTransitionStyle = .crossDissolve
            if callCompleted == false {
                let controller = UIApplication.topViewController()
                DispatchQueue.main.async {
                    controller?.present(nextVC, animated: true)
                }
            }
        }
    }
    
    func addBackPhoto(view: UIView) {
        let backImg = UIImage.init(named: "bgGradient")
        let imgView = UIImageView(image: backImg)
        imgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.insertSubview(imgView, at: 0)
        self.addLogoToNavBar()
    }
    
    func addLogoToNavBar() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "idCard")
        imageView.image = image
        navigationItem.titleView = imageView
    }
    
    func addGradientBackground(view: UIView) {
        let colorManager = SDKColorManager.shared
        colorManager.backgroundGradient.frame = view.bounds
        colorManager.backgroundGradient.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        colorManager.backgroundGradient.position = view.center
        view.layer.insertSublayer(colorManager.backgroundGradient, at: 0)
    }
    
    func showToast(type: ToastType? = .success, title: String, subTitle: String? = "", attachTo: UIView?, delay: Double? = 0.0, callback: @escaping() -> (Void)) {
        let successImg = UIImage.init(systemName: "checkmark.seal.fill")
        let failImg = UIImage.init(systemName: "xmark.seal.fill")
        var currentImg = UIImage()
        var conf = ToastConfiguration(autoHide: true, attachTo: attachTo)
        let successConf = ToastConfiguration(autoHide: true)
        let failConf = ToastConfiguration(autoHide: true, displayTime: 5)
        var hapticType: UINotificationFeedbackGenerator.FeedbackType

        var toast = Toast.default(
            image: currentImg,
            title: "Identify",
            subtitle: "SDK"
        )
        
        switch type {
            case .success:
                currentImg = successImg!
                conf = successConf
                hapticType = .success
            case .fail:
                currentImg = failImg!
                conf = failConf
                hapticType = .error
            default:
                return
        }
        
        if let haveSub = subTitle, subTitle != "" {
            toast = Toast.default(
                image: currentImg,
                title: title,
                subtitle: haveSub,
                configuration: conf
            )
        } else {
            toast = Toast.default(
                image: currentImg,
                title: title,
                configuration: conf
            )
        }
        DispatchQueue.main.async {
            toast.show(haptic: hapticType, after: delay!)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            callback()
        })
    }
    
    func translate(text: SDKKeywords) -> String {
        return languageManager.translate(key: text)
    }
}


class SDKBaseViewController: SDKViewOptionsController {
    
    let nc = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        nc.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() { }

    @objc func appMovedToForeground() {
        if let socket = manager.socket {
            if socket.isConnected == false {
                self.listenToSocketConnection(callCompleted: false)
            }
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
//        self.navigationItem.hidesBackButton = true
        if parent == nil {
            self.manager.moduleStepOrder -= 1
        } else {
            self.manager.moduleStepOrder += 1
        }
    }
    
   
    
}

var vSpinner : UIView?

extension UIViewController {
    
    func showLoader() {
        let spinnerView = UIView.init(frame: self.view.frame)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

public enum ToastType: String {
    case success
    case fail
}

extension SDKViewOptionsController: SDKNoConnectionDelegate {
    
    func reconnectCompleted() { // bağlantı koptu, no internet ekranı geldi, sonra bağlantı yeniden kurulduysa
        self.isAlreadyShowingReConnectScreen = false // üst üste ekran açmasını engellemek için ekledik
    }
    
    
}
