//
//  LoginViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/30.
//

import UIKit
import AuthenticationServices
import KeychainSwift

class LoginViewController: UIViewController {

    @IBOutlet var mainLabel: UILabel!

    @IBOutlet var startButton: UIButton!
    @IBOutlet var imageContainView: UIView!
    @IBOutlet var loginStackView: UIStackView!

    func shadowWeather(inputView: UIView) {
        inputView.layer.shadowColor = UIColor.black.cgColor
        inputView.layer.shadowOpacity = 0.9
        inputView.layer.shadowRadius = 10
        inputView.layer.shadowOffset = CGSize(width: 0, height: 1)
        inputView.layer.shadowPath = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shadowWeather(inputView: imageContainView)


        let loginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        loginButton.addTarget(self, action: #selector(startAppleIDButton), for: .touchUpInside)

        self.loginStackView.addArrangedSubview(loginButton)

        let keychain = KeychainSwift()
        if let id = keychain.get(Keys.id.rawValue) {
            if let value = keychain.get(Keys.provider.rawValue), let provider = Provider(rawValue: value) {
                switch provider {
                case .apple:
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
                            @unknown default:
                                print(error)
                            }
                        }
                    }
                case .naver:
                    break
                case .kakao:
                    break
                }
            }
        }

    }

    @objc func startAppleIDButton() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()

    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let id = credential.user
            let email = credential.email
            let fullName = credential.fullName?.formatted() ?? "방문객님"

            let keychain = KeychainSwift()

            keychain.set(Provider.apple.rawValue, forKey: Keys.provider.rawValue)
            keychain.set(id, forKey: Keys.id.rawValue)

            if let email {
                keychain.set(email, forKey: Keys.email.rawValue)
            }

            if let fullName = credential.fullName?.formatted(), fullName.count > 0 {
                keychain.set(fullName, forKey: Keys.name.rawValue)
            }
            mainLabel.text = "\(fullName), 안녕하세요 :)"
            print(keychain.get(Keys.id.rawValue), keychain.get(Keys.email.rawValue), keychain.get(Keys.name.rawValue))
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
    case provider = "com.leehongryul.myDogGallery.provider"
}

enum Provider: String {
    case apple
    case kakao
    case naver
}
