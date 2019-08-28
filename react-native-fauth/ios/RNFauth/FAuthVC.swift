//
//  FAuthVC.swift
//  DemoAuthenFramework
//
//  Created by Ken on 8/9/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import AppAuth
import CommonCrypto

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

protocol FAuthenDelegate:class {
  func onComplete(data: String)
  func onFail()
}

class FAuthVC: UIViewController {
  weak var fAuthDelegate:FAuthenDelegate?
  var window: UIWindow?
  var appDelegate:AppDelegate!
  var codeVerifier:String = ""
  var isLoaded = false
  var rsData: Any?
  @objc public var params:NSDictionary?
  
  var kOIDCissuer: String = "";
  var kClientID: String? = "";
  var kRedirectURI: String = "";
  var kAppAuthExampleAuthStateKey: String = "";
  var kClientSecret: String = "";
  var kScope: [String] = [];
  
  private var authState: OIDAuthState?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.view.backgroundColor = UIColor.white
    
    appDelegate = UIApplication.shared.delegate as? AppDelegate
    fAuthDelegate = self
    self.loadState()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if(!isLoaded){
      if let data = params as? [String:String] {
        var arrScope:[String] = []
        if let s:String = data[FUtils.RN_PARAMS.scope.rawValue]{
          if s.count > 0 {
            arrScope = s.components(separatedBy: ",")
          }
        }
        
        authenFID(kOIDCissuer: data[FUtils.RN_PARAMS.oidc_issuer.rawValue]!
                , kClientID: data[FUtils.RN_PARAMS.clientID.rawValue]!
                , kRedirectURI: data[FUtils.RN_PARAMS.redirectURI.rawValue]!
                , kClientSecret: data[FUtils.RN_PARAMS.clientSecret.rawValue]!
                , kScope: arrScope
                , authorizationEndpoint: data[FUtils.RN_PARAMS.authorizationEndpoint.rawValue]!
                , tokenEndpoint: data[FUtils.RN_PARAMS.tokenEndpoint.rawValue]!)
        isLoaded = true
        return
      }
      dismiss(animated: false, completion: nil)
    }else{
      if rsData == nil{
        self.sendAuthenResultToJS(data:"")
      }
      
      dismiss(animated: false, completion: nil)
    }
  }
}

//MARK: Response
extension FAuthVC: FAuthenDelegate{
  func onComplete(data: String) {
    self.sendAuthenResultToJS(data: data)
  }
  
  func onFail() {
    self.dismiss(animated: true, completion: nil)
  }
}

//MARK: Logic
extension FAuthVC {
  func genCodeChallenge() -> String{
    //Generate code_verifier
    var buffer_verifier = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer_verifier.count, &buffer_verifier)
    let verifier = Data(bytes: buffer_verifier).base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
      .trimmingCharacters(in: .whitespaces)
    
    print("veryfier: \(verifier)")
    //code_challenge
    // You need to import CommonCrypto
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
  
  func authenFID(kOIDCissuer:String, kClientID:String, kRedirectURI:String, kClientSecret:String, kScope:[String], authorizationEndpoint:String, tokenEndpoint: String) {
    //Validate
//    var msg:String? = nil
//    if kOIDCissuer.isEmpty{
//      msg = "OIDC is not empty!"
//    } else if kClientID.isEmpty{
//      msg = "Client ID is not empty!"
//    } else if kRedirectURI.isEmpty{
//      msg = "Redirect is not empty!"
//    }else if kClientSecret.isEmpty{
//      msg = "Client Secret is not empty!"
//    }else if authorizationEndpoint.isEmpty{
//      msg = "Authorization Endpoint is not empty!"
//    }else if tokenEndpoint.isEmpty{
//      msg = "Token Endpoint is not empty!"
//    }
//    
//    if let m = msg{
//      DispatchQueue.main.async {
//        self.showAlertMessage(message: m)
//        return
//      }
//    }
    
    self.kOIDCissuer = kOIDCissuer
    self.kClientID = kClientID
    self.kRedirectURI = kRedirectURI
    self.kClientSecret = kClientSecret
    self.kScope = kScope.count == 0 ? [OIDScopeOpenID, OIDScopeProfile] : kScope
    
    let authEndpoint = URL(string: "\(authorizationEndpoint)?code_challenge=\(self.genCodeChallenge())&code_challenge_method=S256")
    let token = URL(string: tokenEndpoint)
    
    // discovers endpoints
    OIDAuthorizationService.discoverConfiguration(forIssuer: URL(string: kOIDCissuer)!) { configuration, error in
      let config = OIDServiceConfiguration(authorizationEndpoint: authEndpoint!, tokenEndpoint: token!)
      
      //            guard let config = configuration1 else {
      //                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
      //                self.setAuthState(nil)
      //                return
      //            }
      
      self.logMessage("Got configuration: \(config)")
      
      if let clientId = self.kClientID {
        self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: self.kClientSecret)
      } else {
        self.doClientRegistration(configuration: config) { configuration, response in
          
          guard let configuration = configuration, let clientID = response?.clientID else {
            self.logMessage("Error retrieving configuration OR clientID")
            return
          }
          
          self.doAuthWithAutoCodeExchange(configuration: configuration,
                                          clientID: clientID,
                                          clientSecret: response?.clientSecret)
        }
      }
    }
  }
  
  func logout() {
    let alert = UIAlertController(title: nil,
                                  message: nil,
                                  preferredStyle: UIAlertController.Style.actionSheet)
    
    let clearAuthAction = UIAlertAction(title: "Clear OAuthState", style: .destructive) { (_: UIAlertAction) in
      self.setAuthState(nil)
      //            self.updateUI()
    }
    alert.addAction(clearAuthAction)
    
    let clearLogs = UIAlertAction(title: "Clear Logs", style: .default) { (_: UIAlertAction) in
      DispatchQueue.main.async {
        //                self.logTextView.text = ""
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    
    alert.addAction(clearLogs)
    alert.addAction(cancelAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  func showAlertMessage(message:String){
    let alert = UIAlertController(title: "Alert",
                                  message: message,
                                  preferredStyle: UIAlertController.Style.alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    
    alert.addAction(cancelAction)
    self.present(alert, animated: true, completion: nil)
  }
}

//MARK: AppAuth Methods
extension FAuthVC {
  
  func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
    
    guard let redirectURI = URL(string: kRedirectURI) else {
      self.logMessage("Error creating URL for : \(kRedirectURI)")
      return
    }
    
    let request: OIDRegistrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                                 redirectURIs: [redirectURI],
                                                                 responseTypes: nil,
                                                                 grantTypes: nil,
                                                                 subjectType: nil,
                                                                 tokenEndpointAuthMethod: "client_secret_post",
                                                                 additionalParameters: nil)
    
    // performs registration request
    self.logMessage("Initiating registration request")
    
    OIDAuthorizationService.perform(request) { response, error in
      
      if let regResponse = response {
        self.setAuthState(OIDAuthState(registrationResponse: regResponse))
        self.logMessage("Got registration response: \(regResponse)")
        callback(configuration, regResponse)
      } else {
        self.logMessage("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
        self.setAuthState(nil)
      }
    }
  }
  
  func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
    
    guard let redirectURI = URL(string: kRedirectURI) else {
      self.logMessage("Error creating URL for : \(kRedirectURI)")
      return
    }
//
//    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//      self.logMessage("Error accessing AppDelegate")
//      return
//    }
    
    // builds authentication request
    let request = OIDAuthorizationRequest(configuration: configuration,
                                          clientId: clientID,
                                          clientSecret: clientSecret,
                                          scopes: kScope,
                                          redirectURL: redirectURI,
                                          responseType: OIDResponseTypeCode,
                                          additionalParameters: nil)
    
    // performs authentication request
    logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
    appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
      
      var returnValues:[String: Any] = [:]
      if let authState = authState {
        self.setAuthState(authState)
        returnValues["accessToken"] = authState.lastTokenResponse?.accessToken ?? ""
        returnValues["idToken"] = authState.lastTokenResponse?.idToken ?? ""
        returnValues["refreshToken"] = authState.lastTokenResponse?.refreshToken ?? ""
        
        //                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
        
        self.logMessage("myToken: \(returnValues.description)")

        self.onComplete(data: returnValues.description)
      } else {
        self.onFail()
        self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
        self.setAuthState(nil)
      }
    }
  }
}

//MARK: OIDAuthState Delegate
extension FAuthVC: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
  
  func didChange(_ state: OIDAuthState) {
    self.stateChanged()
  }
  
  func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
    self.logMessage("Received authorization error: \(error)")
  }
}

//MARK: Helper Methods
extension FAuthVC {
  
  func saveState() {
    
    var data: Data? = nil
    
    if let authState = self.authState {
      data = NSKeyedArchiver.archivedData(withRootObject: authState)
    }
    
    UserDefaults.standard.set(data, forKey: kAppAuthExampleAuthStateKey)
    UserDefaults.standard.synchronize()
  }
  
  func loadState() {
    guard let data = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
      return
    }
    
    if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
      self.setAuthState(authState)
    }
  }
  
  func setAuthState(_ authState: OIDAuthState?) {
    if (self.authState == authState) {
      return;
    }
    self.authState = authState;
    self.authState?.stateChangeDelegate = self;
    self.stateChanged()
  }
  
  
  func stateChanged() {
    self.saveState()
  }
  
  func logMessage(_ message: String?) {
    
    guard let message = message else {
      return
    }
    
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm:ss";
    let dateString = dateFormatter.string(from: Date())
    
    // appends to output log
    DispatchQueue.main.async {
      let logText = "\(dateString): \(message)"
      print(logText)
      
    }
  }
  
  @objc func sendAuthenResultToJS(data: Any){
    rsData = data
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      print("test_1: \(self.appDelegate)")
      print("test_2: \(self.appDelegate.rootView)")
      print("test_3: \(self.appDelegate.rootView.bridge)")
      print("test_4")
      if let bridge = self.appDelegate.rootView.bridge {
        if let eventEmitter = bridge.module(for: FAuthenLib.self) as? RCTEventEmitter {
          eventEmitter.sendEvent(withName: FUtils.EVT_AUTHEN, body: data)
        }
      }
    }
  }
}
