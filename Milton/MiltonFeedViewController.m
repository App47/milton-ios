//
//  MiltonFeedViewController.m
//  Milton
//
//  Created by Chris Schroeder on 10/19/11.
//  Copyright (c) 2011 App47. All rights reserved.
//

#import "MiltonFeedViewController.h"
#import "MWFeedItem.h"
#import "EmbeddedAgent.h"

@interface MiltonFeedViewController()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSMutableArray *feedItems;
@property (strong) NSString *feedLoadEventID;
@end


@implementation MiltonFeedViewController
@synthesize url=_url;
@synthesize feedItems=_feedItems;
@synthesize feedLoadEventID=_feedLoadEventID;

- (id) initWithURL:(NSURL *) url{
  self = [super initWithStyle:UITableViewStylePlain];
  if (self ){
    [self setUrl:url];
    [self setFeedItems:[[NSMutableArray alloc]init]];
  }
  return self;
}


#pragma mark - View lifecycle


- (void)viewDidAppear:(BOOL)animated {
  MWFeedParser *parser = [[MWFeedParser alloc]initWithFeedURL:[self url]];
  [parser setDelegate:self];
  // We are going to send the parser to a background thread so that the UI doesn't pause
  [parser parse];
  [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self feedItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  MWFeedItem *item = [[self feedItems] objectAtIndex:indexPath.row];
  
  [[cell textLabel] setText:[item title]];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateStyle:NSDateFormatterMediumStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [[cell detailTextLabel] setText:[formatter stringFromDate:[item date]]];
  
  return cell;
}

#pragma mark - MWFeedParserDelgate

- (void)feedParserDidStart:(MWFeedParser *)parser{
  NSString *eventName = [NSString stringWithFormat:@"Load feed %@",[[[self navigationController] tabBarItem] title]];
  EALogDebug(@"Started parsing feed: %@", eventName);
  [self setFeedLoadEventID:[EmbeddedAgent startTimedEvent:eventName]];
  
}
- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info{
  // Set the title of the nav controller, make sure it's done on the main thread
  // as we sent the parser to the background.
  [[self navigationItem] performSelectorOnMainThread:@selector(setTitle:) 
                                          withObject:[info title] 
                                       waitUntilDone:NO];
}
- (void) addFeedItem:(MWFeedItem *) item{
  NSIndexPath *path = [NSIndexPath indexPathForRow:[[self feedItems]count] inSection:0];
  [[self tableView] beginUpdates];
  [[self feedItems] addObject:item];
  [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:path] 
                          withRowAnimation:UITableViewRowAnimationFade];
  [[self tableView] endUpdates];
}
- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item{
  // Send back to the main UI thread.
  [self performSelectorOnMainThread:@selector(addFeedItem:) withObject:item waitUntilDone:NO];  
}
- (void)feedParserDidFinish:(MWFeedParser *)parser{
  NSString *eventName = [NSString stringWithFormat:@"Load feed %@",[[[self navigationController] tabBarItem] title]];
  EALogDebug(@"Done parsing feed: %@", eventName);
  [EmbeddedAgent endTimedEvent:[self feedLoadEventID]];
}
- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error{
  NSString *eventName = [NSString stringWithFormat:@"Feed (@%) failed to load",[[[self navigationController] tabBarItem] title]];
  [EmbeddedAgent sendGenericEvent:eventName];
  EALogErrorWithError(error, @"Unable to parse feed %@", [self url]);
  UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"Unable to parse feed" 
                                                message:[error localizedDescription] 
                                               delegate:nil 
                                      cancelButtonTitle:@"OK" 
                                      otherButtonTitles: nil];
  [view performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}


@end
