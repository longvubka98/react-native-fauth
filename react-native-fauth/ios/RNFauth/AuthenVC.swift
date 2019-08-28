//
//  AuthenVC.swift
//  DemoAuthenFramework
//
//  Created by Ken on 7/5/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import CommonCrypto

class AuthenVC: UIViewController, UINavigationControllerDelegate {
  var window: UIWindow?
  var codeVerifier:String = ""
  var isLoaded = false
  var rsData: Any?
  var delegate:AppDelegate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.view.backgroundColor = UIColor.white
    
    delegate = UIApplication.shared.delegate as? AppDelegate
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if(!isLoaded){
      authenFtech()
      isLoaded = true
    }else{
      if rsData == nil{
        self.sendAuthenResultToJS(data:"")
      }
      
      dismiss(animated: false, completion: nil)
    }
  }
  
  
  @objc func authenFID(sender: UIButton){
        authenFtech()
  }
  
  func presentAlert(_ title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func authenFtech(){
//    let oauthswift = OAuth2Swift(
//      consumerKey: FUtils.CLIENT_ID,
//      consumerSecret: "",    // No secret required
//      authorizeUrl: "\(FUtils.URL_HOST)/connect/authorize?code_challenge=\(genCodeChallenge())&code_challenge_method=S256",
//      accessTokenUrl: "\(FUtils.URL_HOST)/connect/token",
//      responseType: "code"
//    )
//    
//    oauthswift.allowMissingStateCheck = true
//    oauthswift.codeVerifier = codeVerifier
//    oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
//    
//    guard let rwURL = URL(string: FUtils.CALL_BACK_URL) else { return }
//    
//    oauthswift.authorize(withCallbackURL: rwURL, scope: "api", state: "", success: { (credential, response, parameters) in
//      
//      self.sendAuthenResultToJS(data: parameters)
//      self.codeVerifier = ""
//    }) { (error) in
//      self.presentAlert("Error", message: error.localizedDescription)
//    }
  }
  
  func genCodeChallenge() -> String{
    //Generate code_verifier
    var buffer_verifier = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer_verifier.count, &buffer_verifier)
    let verifier = Data(bytes: buffer_verifier).base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
      .trimmingCharacters(in: .whitespaces)
    
    codeVerifier = verifier
    //code_challenge
    guard let data = verifier.data(using: .utf8) else { return "" }
    
    var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
    }
    let hash = Data(bytes: buffer)
    let challenge = hash.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
      .trimmingCharacters(in: .whitespaces)
    
    return challenge
  }
  
}

extension AuthenVC{
  @objc func sendAuthenResultToJS(data: Any){
    rsData = data
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      if let bridge = self.delegate.rootView.bridge {
        if let eventEmitter = bridge.module(for: FAuthenLib.self) as? RCTEventEmitter {
          eventEmitter.sendEvent(withName: FUtils.EVT_AUTHEN, body: data)
        }
      }
    }
  }
  
}
