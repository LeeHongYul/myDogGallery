//
//  LoginViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/30.
//

import UIKit
import AuthenticationServices
import KeychainSwift

class LoginViewController: BaseViewController {

    @IBOutlet var mainLabel: UILabel!

    @IBOutlet var startButton: StartButton!
    @IBOutlet var imageContainView: UIView!
    @IBOutlet var loginStackView: UIStackView!

    // 앱이 시작될 때, 로그인 아이디가 키 체인에 이미 저장되어 있는 경우 해당 아이디를 사용하여 자동으로 로그인하도록 구현
    @IBAction func startButton(_ sender: Any) {
        let keychain = KeychainSwift()
        if let id = keychain.get(Keys.id.rawValue) {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    // LoginViewController가 다시 나타날 때 (로그아웃한 후), startButton을 숨기도록 구현
    override func viewWillAppear(_ animated: Bool) {
        startButton.isHidden = true
    }

    func checkSignInID() {

        let loginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        loginButton.addTarget(self, action: #selector(startAppleIDButton), for: .touchUpInside)

        self.loginStackView.addArrangedSubview(loginButton)

        let keychain = KeychainSwift()
        if let id = keychain.get(Keys.id.rawValue) {
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: id) { state, error in
                if let error {
                    print(error)
                    return
                }

                DispatchQueue.main.async {
                    switch state {
                    case .authorized:
                        if let name = keychain.get(Keys.name.rawValue) {
                            self.mainLabel.text = "\(name)님, 안녕하세요 :)"
                        }
                        loginButton.isHidden = true
                        self.startButton.isHidden = false
                    @unknown default:
                        print(error)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageContainView.setShadow(color: .black, opacity: 0.9, radius: 10, offset: CGSize(width: 0, height: 1))
        checkSignInID()
    }

    @objc func startAppleIDButton() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 키 체인을 사용하여 데이터가 저장되어 있는지 확인한 후, 해당 데이터를 사용하여 사용자 이름을 mainLabel에 표시
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let id = credential.user
            let email = credential.email
            let fullName = credential.fullName?.formatted() ?? "방문객님"

            let keychain = KeychainSwift()

            keychain.set(id, forKey: Keys.id.rawValue)

            if let email {
                keychain.set(email, forKey: Keys.email.rawValue)
            }

            if let fullName = credential.fullName?.formatted(), fullName.count > 0 {
                keychain.set(fullName, forKey: Keys.name.rawValue)
            }

            mainLabel.text = "\(fullName), 안녕하세요 :)"
            // 키 체인을 사용하여 데이터가 저장되어 있는지 확인하는 코드

            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}

enum Keys: String {
    case id = "com.leehongryul.myDogGallery.id"
    case email = "com.leehongryul.myDogGallery.email"
    case name = "com.leehongryul.myDogGallery.name"
}
