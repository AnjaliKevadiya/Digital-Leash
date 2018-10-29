//
//  AppDelegate.h
//  DigitalLeashChild
//
//  Created by Anjali Kevadiya on 10/18/18.
//  Copyright © 2018 Anjali Kevadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(BOOL)isNetworkRechability;

@end

