//
//  FAuthenLib.swift
//  DemoAuthenFramework
//
//  Created by Ken on 7/5/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import UIKit

@objc(FAuthenLib)
class FAuthenLib: RCTEventEmitter {
    override init() {
      super.init()
  //    EventEmitter.sharedInstance.registerEventEmitter(eventEmitter: self)
    }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  @objc open override func supportedEvents() -> [String] {
    return [FUtils.EVT_AUTHEN]
  }
  
  @objc(showAuthenVC:)
  func showAuthenVC(arr: NSArray) -> Void {
    
    let userInfo = [FUtils.RN_PARAMS.oidc_issuer.rawValue: arr[0]
      ,FUtils.RN_PARAMS.clientID.rawValue: arr[1]
      ,FUtils.RN_PARAMS.redirectURI.rawValue: arr[2]
      ,FUtils.RN_PARAMS.clientSecret.rawValue: arr[3]
      ,FUtils.RN_PARAMS.scope.rawValue: arr[4]
      ,FUtils.RN_PARAMS.authorizationEndpoint.rawValue: arr[5]
      ,FUtils.RN_PARAMS.tokenEndpoint.rawValue: arr[6]
    ]
    NotificationCenter.default.post(name: NSNotification.Name(FUtils.NOTIFI_SHOW_AUTHEN_VC), object: self, userInfo:userInfo)
    
  }
}
