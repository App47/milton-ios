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



- (void) updateTabsFromConfiguration {
  // Make sure we are running on the main thread.
  if (NO==[NSThread isMainThread]){
    [self performSelectorOnMainThread:@selector(updateTabsFromConfiguration) withObject:nil waitUntilDone:NO];
    return;
  }
  // Get the tab list group name from the main UI configuration group
  NSString *tabGroupName = [EmbeddedAgent configurationObjectForKey:TAB_LISTING_NAME group:UI_CONFIGURATION_GROUP_NAME];
  // Get a list of all keys from the tab list group
  NSArray *tabKeys = [[EmbeddedAgent allKeysForConfigurationGroup:tabGroupName] 
                      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return [obj1 caseInsensitiveCompare:obj2];
  }];
  EALogDebug(@"Got the following keys back from App47: %@", tabKeys);
  
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
