//
//  SDKListenSocketViewController.swift
//  NewTest
//
//  Created by Emir Beytekin on 22.11.2022.
//

import UIKit

protocol SDKNoConnectionDelegate: class {
    func reconnectCompleted()
}

class SDKListenSocketViewController: SDKBaseViewController {

    @IBOutlet weak var reConnectBtn: IdentifyButton!
    weak var delegate: SDKNoConnectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        reConnectBtn.setTitle(self.translate(text: .coreReConnect), for: .normal)
        reConnectBtn.type = .submit
        reConnectBtn.onTap = {
            self.manager.reconnectToSocket { [weak self] resp in
                guard let self = `self` else { return }
                if resp.isConnected {
                    self.delegate?.reconnectCompleted()
                    print("tekrar bağlantı kuruldu")
                    self.dismiss(animated: true)
                }
            }
        }
        reConnectBtn.populate()
    }

}
