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
@property (strong, nonatomic) NSString *feedLoadEventID;
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

- (void)viewDidLoad {
  [super viewDidLoad];
  
  MWFeedParser *parser = [[MWFeedParser alloc]initWithFeedURL:[self url]];
  [parser setDelegate:self];
  [parser parse];
  
}


- (void)viewWillAppear:(BOOL)animated {
  [[self tableView] reloadData];
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
}


#pragma mark - MWFeedParserDelgate

- (void)feedParserDidStart:(MWFeedParser *)parser{
  NSString *eventName = [NSString stringWithFormat:@"Load feed %@",[[self tabBarItem] title]];
  [self setFeedLoadEventID:[EmbeddedAgent startTimedEvent:eventName]];
  
}
- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info{
  // Set the title of the nav controller
  [[self navigationItem] setTitle:[info title]];
}
- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item{
  
  NSIndexPath *path = [NSIndexPath indexPathForRow:[[self feedItems]count] inSection:0];
  [[self feedItems] addObject:item];
  [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:path] 
                          withRowAnimation:UITableViewRowAnimationBottom];
  
}
- (void)feedParserDidFinish:(MWFeedParser *)parser{
  [EmbeddedAgent endTimedEvent:[self feedLoadEventID]];
}
- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error{
  [EmbeddedAgent endTimedEvent:[self feedLoadEventID]];
  EALogErrorWithError(error, @"Unable to parse feed %@", [self url]);
  UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"Unable to parse feed" 
                                                message:[error localizedDescription] 
                                               delegate:nil 
                                      cancelButtonTitle:@"OK" 
                                      otherButtonTitles: nil];
  [view show];
}


@end
