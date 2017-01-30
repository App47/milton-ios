//
//  MiltonFeedViewController.h
//  Milton
//
//  Copyright (c) 2011 App47. All rights reserved.
//

#import "MWFeedParser.h"

@interface MiltonFeedViewController : UITableViewController<MWFeedParserDelegate>


- (id) initWithURL:(NSURL *) url;

@end
