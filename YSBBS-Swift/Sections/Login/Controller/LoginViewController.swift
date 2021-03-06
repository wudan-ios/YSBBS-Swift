//
//  LoginViewController.swift
//  YSBBS-Swift
//
//  Created by wudan on 2019/2/18.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit
import SnapKit

let LoginSuccessNotification = "LoginSuccess"

class LoginViewController: UIViewController {
    
    /// Logo Icon
    private lazy var logoIconImageView: UIImageView = {
        let img                = UIImageView.init()
        img.image              = UIImage.init(named: "Y")
        img.layer.cornerRadius = 30 * kSCREEN_RATE_WIDTH
        img.layer.borderColor  = UIColor.black.cgColor
        img.layer.borderWidth  = 0.5
        return img
    }()
    
    /// Login button
    private lazy var loginButton: UIButton = {
        let b                  = UIButton.init(type: .custom)
        let image              = UIImage.init(named: "loing_btn_normal_50x50_")
        b.imageView!.tintColor = kMain_Color_line_dark.withAlphaComponent(0.5)
        b.setImage(image, for: .normal)
        b.currentImage?.withRenderingMode(.alwaysTemplate)
        b.addTarget(self, action: #selector(loginButtonTouched(sender:)), for: .touchUpInside)
        return b
    }()
    
    /// Account name or email
    private lazy var accountTextField: WD_TextField = {
        let textField           = WD_TextField()
        textField.placeholder   = "邮箱/账号";
        textField.returnKeyType = .next
        textField.leftView      = UIImageView.init(image: UIImage.init(named: "login_phone number_12x16_"))
        return textField
    }()
    
    /// password
    private lazy var pwdTextField: WD_TextField = {
        let t               = WD_TextField()
        t.placeholder       = "密码";
        t.isSecureTextEntry = true
        t.clearButtonMode   = .always
        t.returnKeyType     = .done
        t.leftView          = UIImageView.init(image: UIImage.init(named: "login_password_14x16_"))
        return t
    }()
    
    /// Decription of log icon
    private lazy var logoDecriptionLabel: UILabel = {
        let l           = UILabel.init()
        l.numberOfLines = 0
        l.text          = "易社，一个专注于帖子的APP"
        l.textColor     = UIColor.lightGray
        l.textAlignment = .center
        l.font          = UIFont.init(name: "Patriciana", size: 15 * UIScreen.main.bounds.width / 375.0)
        return l
    }()
    
    // Third login way button
    private lazy var thirdLoginArray: [UIButton] = {
        var array: [UIButton] = Array()
        let imageArray: [String] = ["login_qq_btn_61x61_", "login_wechat_btn_61x61_", "login_weibo_btn_61x61_"]
        for (_, index) in imageArray.enumerated() {
            let b = UIButton.init(type: .custom)
            view.addSubview(b)
            b.setImage(UIImage.init(named: index), for: .normal)
            array.append(b)
        }
        return array
    }()
    
    /// Register
    private lazy var registerButton: UIButton = {
        let b              = UIButton.init(type: .custom)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13 * UIScreen.main.bounds.width / 375.0)
        b.tag              = 11
        b.setTitle("还没有账号？", for: .normal)
        b.setTitleColor(kMain_Color_line_dark, for: .normal)
        b.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside)
        return b
    }()
    
    /// Forget password
    private lazy var forgetPwdbutton: UIButton = {
        let b              = UIButton.init(type: .custom)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13 * UIScreen.main.bounds.width / 375.0)
        b.tag              = 12
        b.setTitle("忘记密码？", for: .normal)
        b.setTitleColor(kMain_Color_line_dark, for: .normal)
        b.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside)
        return b
    }()
    
    private lazy var guestButton: UIButton = {
        let b = UIButton.init()
        b.setTitle(" 游客访问 ", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        b.layer.cornerRadius = 3
        b.layer.borderColor = UIColor.black.cgColor
        b.layer.borderWidth = 0.3
        b.addTarget(self, action: #selector(guestButtonDidtapped), for: .touchUpInside)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        hx_backgroundColor = .clear
        hx_shadowHidden = true
        hx_barAlpha = 0
        title = ""
        setupSubViews()
        blockHandler()
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: guestButton)
    }
}

// MARK: - Touch event
@objc extension LoginViewController {
    
    func guestButtonDidtapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func buttonTouched(sender: UIButton) {
        let vc = Login_EmailViewController()
        switch sender.tag {
        case 11:
            vc.title = "注册账号"
            vc.emailType = .register
            navigationController?.pushViewController(vc, animated: true)
        default:
            vc.title = "忘记密码"
            vc.emailType = .forgetPassword
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func loginButtonTouched(sender: UIButton) {
        view.endEditing(true)
        
        if let accountLenth = accountTextField.text {
            if accountLenth.count == 0 {
                HUDUtils.showWarningHUD(string: "请输入账号或者邮箱")
                return
            }
        }
        
        if let pwdLenth = pwdTextField.text {
            if pwdLenth.count == 0 {
                HUDUtils.showWarningHUD(string: "请输入密码")
                return
            }
        }
        
        YSNetWorking().login(with: accountTextField.text!, password: pwdTextField.text!, successComplete: { (data) -> (Void) in
            if let code:Int = data["code"] as? Int {
                if code != 0 {
                    HUDUtils.showErrorHUD(string: (data["msg"] as! String))
                } else {
                    HUDUtils.showSuccessHUD(string: "登陆成功")
                    UserDefaults.standard.set(true, forKey: kIsLogin)
                    UserDefaults.standard.set((data["data"] as! String), forKey: kHeaderToken)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: LoginSuccessNotification), object: nil, userInfo: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }            
        }) { (error) -> (Void) in
            print(error)
        }
    }
}

// MARK: - Set up layout
extension LoginViewController {
    
    func blockHandler() {
        accountTextField.textFieldChangeHandler = { [weak self] (text: String, textField: WD_TextField) -> Void in
            guard let strongSelf = self else { return }
            if text.count > 0 && (strongSelf.pwdTextField.text?.count)! > 0 {
              strongSelf.loginButton.imageView!.tintColor = kMain_Color_line_dark
            } else {
              strongSelf.loginButton.imageView!.tintColor = kMain_Color_line_dark.withAlphaComponent(0.5)
            }
        }
        
        accountTextField.textFieldNextResponseHandler = {[weak self] (textField: WD_TextField) in
            guard let strongSelf = self else { return }
            strongSelf.accountTextField.resignFirstResponder()
            strongSelf.pwdTextField.becomeFirstResponder()
        }
        
        pwdTextField.textFieldNextResponseHandler = {[weak self] (textField: WD_TextField) in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
        }
        
        pwdTextField.textFieldChangeHandler = {[weak self] (text: String, textField: WD_TextField) -> Void in
            guard let strongSelf = self else { return }
            if text.count > 0 && (self!.accountTextField.text?.count)! > 0 {
                strongSelf.loginButton.imageView!.tintColor = kMain_Color_line_dark
            } else {
                strongSelf.loginButton.imageView!.tintColor = kMain_Color_line_dark.withAlphaComponent(0.5)
            }
        }
    }
    
    func setupSubViews() {
        view.addSubview(logoIconImageView)
        logoIconImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(kSafeAreaTopHeight)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100 * kSCREEN_RATE_WIDTH, height: 100 * kSCREEN_RATE_WIDTH))
        }
        
        view.addSubview(logoDecriptionLabel)
        logoDecriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoIconImageView.snp.bottom).offset(30 * kSCREEN_RATE_HEIGHT)
            make.leading.trailing.equalToSuperview().inset(30 * kSCREEN_RATE_WIDTH)
        }
        
        view.addSubview(accountTextField)
        accountTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.centerY).offset(-15 * kSCREEN_RATE_HEIGHT)
            make.leading.trailing.equalToSuperview().inset(30 * kSCREEN_RATE_WIDTH)
            make.height.equalTo(45 * kSCREEN_RATE_HEIGHT)
        }
        
        view.addSubview(pwdTextField)
        pwdTextField.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.centerY).offset(15 * kSCREEN_RATE_HEIGHT)
            make.leading.trailing.equalToSuperview().inset(30 * kSCREEN_RATE_WIDTH)
            make.height.equalTo(45 * kSCREEN_RATE_HEIGHT)
        }
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(pwdTextField.snp.bottom).offset(30 * kSCREEN_RATE_HEIGHT)
        }
      
        thirdLoginArray.snp.distributeViewsAlong(axisType: .horizontal,
                                                 fixedSpacing: 10 * kSCREEN_RATE_WIDTH,
                                                 leadSpacing: 15 * kSCREEN_RATE_WIDTH,
                                                 tailSpacing: 15 * kSCREEN_RATE_WIDTH)
        
        thirdLoginArray.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-(15 * kSCREEN_RATE_HEIGHT + kSafeAreaBottomHeight))
        }
        
        view.addSubview(registerButton)
        registerButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            if (kSCREEN_WIDTH <= 320) {
                make.top.equalTo(loginButton.snp.bottom).offset(15 * kSCREEN_RATE_WIDTH)
            } else {
                make.top.equalTo(loginButton.snp.bottom).offset(30 * kSCREEN_RATE_WIDTH)
            }
        }

        view.addSubview(forgetPwdbutton)
        forgetPwdbutton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            if (kSCREEN_WIDTH <= 320) {
                make.top.equalTo(registerButton.snp.bottom);
            } else {
                make.top.equalTo(registerButton.snp.bottom).offset(10 * kSCREEN_RATE_WIDTH)
            }
        }
    }
}
