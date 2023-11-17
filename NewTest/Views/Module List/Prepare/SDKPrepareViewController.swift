//
//  SDKPrepareViewController.swift
//  NewTest
//
//  Created by Emir Beytekin on 13.11.2023.
//

import UIKit

class SDKPrepareViewController: SDKBaseViewController {

    @IBOutlet weak var submitBtn: IdentifyButton!
    var speedCheckDone = false
    @IBOutlet weak var speedStackView: UIStackView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI() {
        guard let needSpeedTest = self.manager.needSpeedTest else {return}
        if needSpeedTest {
            self.submitBtn.setTitle("Bağlantı kalitemi ölç ve devam et", for: .normal)
            self.submitBtn.type = .cancel
        } else {
            self.submitBtn.setTitle(self.translate(text: .continuePage), for: .normal)
            self.submitBtn.type = .submit
        }
        self.submitBtn.onTap = {
            self.startSpeedTest()
        }
        self.submitBtn.alpha = 0.3
        self.submitBtn.isEnabled = false
        self.submitBtn.populate()
        self.setupButtons()
    }
    
    func setupButtons() {
        button1.setTitle("Kimliğim yanımda", for: .normal)
        button1.setTitle("Kimliğim yanımda", for: .selected)
        button1.setImage(UIImage(named: "buttonTick")?.withTintColor(.gray), for: .normal)
        button1.setImage(UIImage(named: "buttonTick"), for: .selected)
        button1.tag = 1
        button1.addTarget(self, action: #selector(checkBoxTapped(_ :)), for: .touchUpInside)
        
        button2.setTitle("Kimlik doğrulama işlemi için yalnızım", for: .normal)
        button2.setTitle("Kimlik doğrulama işlemi için yalnızım", for: .selected)
        button2.setImage(UIImage(named: "buttonTick")?.withTintColor(.gray), for: .normal)
        button2.setImage(UIImage(named: "buttonTick"), for: .selected)
        button2.tag = 2
        button2.addTarget(self, action: #selector(checkBoxTapped(_ :)), for: .touchUpInside)
        
        button3.setTitle("Uygun ışık ve ses koşullarındayım", for: .normal)
        button3.setTitle("Uygun ışık ve ses koşullarındayım", for: .selected)
        button3.setImage(UIImage(named: "buttonTick")?.withTintColor(.gray), for: .normal)
        button3.setImage(UIImage(named: "buttonTick"), for: .selected)
        button3.tag = 3
        button3.addTarget(self, action: #selector(checkBoxTapped(_ :)), for: .touchUpInside)
    }
    
    @objc func checkBoxTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            button1.isSelected = !button1.isSelected
        case 2:
            button2.isSelected = !button2.isSelected
        case 3:
            button3.isSelected = !button3.isSelected
        default:
            return
        }
        self.reloadSubmitButton()
    }
    
    func reloadSubmitButton() {
        if button1.isSelected && button2.isSelected && button3.isSelected {
            self.submitBtn.alpha = 1
            self.submitBtn.isEnabled = true
        } else {
            self.submitBtn.alpha = 0.3
            self.submitBtn.isEnabled = false
        }
    }
    
    func startSpeedTest() {
        if manager.needSpeedTest ?? false == true {
            self.showLoader()
            self.submitBtn.type = .loader
            self.manager.startSpeedTest { connectionStatus, kbPerSec in
                print(kbPerSec)
                self.hideLoader()
                if connectionStatus == .good {
                    DispatchQueue.main.async {
                        self.showToast(title: "Bağlantı kalitesi uygun", attachTo: self.view) {
                                return
                        }
                        self.speedStackView.isHidden = false
                        self.submitBtn.type = .submit
                        self.submitBtn.setTitle(self.translate(text: .continuePage), for: .normal)
                        self.submitBtn.onTap = {
                            self.getNextModule()
                        }
                        self.submitBtn.populate()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showToast(type:.fail, title: "Bağlantı hızı kötü", attachTo: self.view) {
                            return
                        }
                    }
                    // Bağlantı kalitesi düşük ise buradan yönlendirmelerinizi yapabilirsiniz
                }
            }
        } else {
            self.getNextModule()
        }
    }
    
    func getNextModule() {
        self.manager.getNextModule { nextVC in
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }

}
