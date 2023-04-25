//
//  SDKSignatureViewController.swift
//  NewTest
//
//  Created by Emir Beytekin on 8.11.2022.
//

import UIKit
import SwiftSignatureView
import PencilKit

class SDKSignatureViewController: SDKBaseViewController {
    
    @IBOutlet weak var signatureView: SwiftSignatureView!
    @IBOutlet weak var signDescLabel: UILabel!
    @IBOutlet weak var submtBtn: IdentifyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        submtBtn.alpha = 0.3
        submtBtn.isEnabled = false
        self.hideLoader()
        self.signatureView.clear()
    }
    
    private func setupUI() {
        submtBtn.alpha = 0.3
        submtBtn.isEnabled = false
        submtBtn.type = .submit
        submtBtn.setTitle(self.translate(text: .continuePage), for: .normal)
        submtBtn.onTap = {
            self.submitAct()
        }
        submtBtn.populate()
        self.signDescLabel.text = self.translate(text: .signatureInfo)
        
        if #available(iOS 13.0, *) { // dark mode için gerekli
            if let signaturInnerView = signatureView.subviews.first(where: {$0 is ISignatureView}) {
                if let canvasView = signaturInnerView.subviews.first(where: {$0 is PKCanvasView}) {
                canvasView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8470588235)
                }
            }
        }
        signatureView.delegate = self
        self.signatureView.backgroundColor = UIColor.white
    }
    
    private func submitAct() {
        showLoader()
        guard let signatureImg = signatureView.getCroppedSignature() else { return }
        manager.uploadIdPhoto(idPhoto: signatureImg, selfieType: .signature) { webResp in
            self.hideLoader()
            if webResp.result == true {
                self.manager.getNextModule { nextVC in
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
    }

}

extension SDKSignatureViewController: SwiftSignatureViewDelegate {
    func swiftSignatureViewDidDrawGesture(_ view: ISignatureView, _ tap: UIGestureRecognizer) { }
    
    func swiftSignatureViewDidDraw(_ view: ISignatureView) {
        submtBtn.alpha = 1
        submtBtn.isEnabled = true
    }
    
    
}
