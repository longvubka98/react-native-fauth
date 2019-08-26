//
//  FUtils.swift
//  DemoAuthenFramework
//
//  Created by Ken on 7/8/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
//import OAuthSwift

@objc open class FUtils: NSObject{
  @objc static let shared = FUtils()
  //Initializer access level change now
  override init(){}
  
//  @objc func handle(url: URL){
//      OAuthSwift.handle(url: url)
//  }
}

//MARK: CONFIGURE

extension FUtils{
  //Configure host
  @objc static let CLIENT_ID = "native.code"
  @objc static let URL_HOST = "http://192.168.20.48:5000"
  @objc static let CALL_BACK_URL = "appauthtest://callback"
  
  //Configure events name
  @objc static let EVT_AUTHEN = "onAuthenResult"
  
  //Notification name
  @objc static let NOTIFI_SHOW_AUTHEN_VC = "showAuthenVCNotification"
  
  //    let userInfo = [
  //                    "oidc_issuer": arr[0],"clientID": arr[1],
  //                    "redirectURI": arr[2],"clientSecret": arr[3],
  //                    "scope": arr[4],"authorizationEndpoint": arr[5],
  //                    "tokenEndpoint": arr[6],
  //                    ]
  enum RN_PARAMS:String
  {
    case oidc_issuer
    case clientID
    case redirectURI
    case clientSecret
    case scope
    case authorizationEndpoint
    case tokenEndpoint
  }
  
}
