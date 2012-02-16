//
//  MiltonTabBarController.m
//  Milton
//
//  Created by Chris Schroeder on 10/18/11.
//  Copyright (c) 2011 App47. All rights reserved.
//

#import "MiltonTabBarController.h"
#import "EmbeddedAgent.h"
#import "MiltonFeedViewController.h"


#define TAB_LISTING_NAME @"Tab listing"
#define UI_CONFIGURATION_GROUP_NAME @"UI Configuration"

@implementation MiltonTabBarController

// Used if the remote configuration is not found, we want to display something simple, and not fail.
- (void) loadStaticTabs {
  NSMutableArray *viewControllers = [[NSMutableArray alloc]init];
  
  MiltonFeedViewController *controller = [[MiltonFeedViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.app47.com/feed/"]];
  UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:controller];
  UIImage *image = [UIImage imageNamed:@"cellphone.png"];
  
  UITabBarItem *tabBarItem = [[UITabBarItem alloc]initWithTitle:@"App47" image:image tag:500];
  [navController setTabBarItem:tabBarItem];
  [viewControllers addObject:navController];

    [controller release];
    [tabBarItem release];
    [navController release];
 
  controller = [[MiltonFeedViewController alloc] initWithURL:[NSURL URLWithString:@"http://rssfeeds.usatoday.com/usatoday-NewsTopStories"]];
  navController = [[UINavigationController alloc]initWithRootViewController:controller];
  image = [UIImage imageNamed:@"book.png"];
  
  tabBarItem = [[UITabBarItem alloc]initWithTitle:@"USA Today" image:image tag:500];
  [navController setTabBarItem:tabBarItem];
  [viewControllers addObject:navController];


  
  [self setViewControllers:viewControllers animated:YES];
    [controller release];
    [tabBarItem release];
    [navController release];

}
// Update the displayed tabs from configuration. This is expecting at least three configuration groups defined below:
//
// Configuration group 1:
// Name: "UI Configuration"
// Description: The starting point of the UI configuration, today it only has one value, the tab listing name, but
//              in the future it may contain other UI configuration parameters we may want to adjust.
// Expected key/values
// ____________________________________________________
// |  Key          |            Value                 |
// |--------------------------------------------------|
// |  Tab listing  | Tabs                             |
// |--------------------------------------------------|
// 
// Configuration group 2:
// Name: "Tabs"
// Description: Actually the name of this group needs to match the value in the previous table for the 
//              "Tab listing" key. However in our example, it is "Tabs". This group has a list of tabs
//              to display in milton along with their order. The order is the key value and the value is 
//              name of the corresponding group for the tab.
// Expected key/values
// ____________________________________________________
// |  Key          |            Value                 |
// |--------------------------------------------------|
// |  Order        | Name of the group for the tab    |
// |--------------------------------------------------|
//
// Example
// ____________________________________________________
// |  1            | App47                            |
// |--------------------------------------------------|
// 
// Configuration group 3:
// Name: "App47"
// Description: There needs to be one of these groups for each of tabs listed in the previous configuration group.
// Expected key/values
// ____________________________________________________
// |  Key          |            Value                 |
// |--------------------------------------------------|
// |  title        | Title of the tab on the UI       |
// |--------------------------------------------------|
// |  image_name   | Filename for the tab image       |
// |--------------------------------------------------|
// |  url          | URL for the atomic RSS feed      |
// |--------------------------------------------------|
//
// Example
// ____________________________________________________
// |  title        | App47                            |
// |--------------------------------------------------|
// |  image_name   | cellphone.png                    |
// |--------------------------------------------------|
// |  url          | http://www.app47.com/feed/       |
// |--------------------------------------------------|
// 
- (void) updateTabsFromConfiguration {
  // Make sure we are running on the main thread, just defensive coding.
  if (NO==[NSThread isMainThread]){
    [self performSelectorOnMainThread:@selector(updateTabsFromConfiguration) 
                           withObject:nil 
                        waitUntilDone:NO];
    return;
  }
  // Get the tab list group name from the main UI configuration group
  NSString *tabGroupName = [EmbeddedAgent configurationStringForKey:TAB_LISTING_NAME group:UI_CONFIGURATION_GROUP_NAME];
  // Check to make sure we have the tab group name, if not, then load static pages.
  if ([tabGroupName length]<=0){
    [self loadStaticTabs];
    return;
  }
  // Get a list of all keys from the tab list group
  NSArray *tabKeys = [[EmbeddedAgent allKeysForConfigurationGroup:tabGroupName] 
                      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return [obj1 caseInsensitiveCompare:obj2];
  }];
  EALogDebug(@"Got the following keys back from App47: %@", tabKeys);
  // Check to make sure we got more than one tab key back.
  if ([tabKeys count]<=0){
    [self loadStaticTabs];
    return;
  }
  
  NSMutableArray *viewControllers = [[NSMutableArray alloc]init];
  for (NSString *key in tabKeys){
    NSString *groupName = [EmbeddedAgent configurationStringForKey:key group:tabGroupName];
    NSString *tabTitle = [EmbeddedAgent configurationStringForKey:@"title" group:groupName];
    NSString *image_name = [EmbeddedAgent configurationStringForKey:@"image_name" group:groupName];
    NSString *url_string = [EmbeddedAgent configurationStringForKey:@"url" group:groupName];
    NSURL *url = [NSURL URLWithString:url_string];
    
    MiltonFeedViewController *controller = [[MiltonFeedViewController alloc]initWithURL:url];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:controller];
    UIImage *image = [UIImage imageNamed:image_name];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc]initWithTitle:tabTitle image:image tag:500];
    [navController setTabBarItem:tabBarItem];
    [viewControllers addObject:navController];
      [controller release];
      [tabBarItem release];
      [navController release];

    
  }
  [self setViewControllers:viewControllers animated:YES];

}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  // Register ourselves to get updates on configuration changes.
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(updateTabsFromConfiguration) 
                                               name:EmbeddedAgentAppConfigurationGroupDidChange 
                                             object:nil];
  [self updateTabsFromConfiguration];
    [super viewDidLoad];
}

- (void)viewDidUnload {
  // Remove ourselves from observing configuration changes if we get uploaded.
  [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                  name:EmbeddedAgentAppConfigurationGroupDidChange 
                                                object:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
