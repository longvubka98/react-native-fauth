//
//  FAuthenLibBridge.m
//  DemoAuthenFramework
//
//  Created by Ken on 7/6/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(FAuthenLib, RCTEventEmitter)
RCT_EXTERN_METHOD(showAuthenVC:(nonnull NSArray *)array)
@end
