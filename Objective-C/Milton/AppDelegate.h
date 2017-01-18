//
//  AppDelegate.h
//  Milton
//
//  Copyright (c) 2011 App47. All rights reserved.
//

@class MiltonTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MiltonTabBarController *tabBarController;

void handleUncaughtException(NSException *exception) ;

@end
