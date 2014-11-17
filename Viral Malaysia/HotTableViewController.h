//
//  HotTableViewController.h
//  Viral Malaysia
//
//  Created by zer0 on 11/12/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBStoreHouseRefreshControl;

@interface HotTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIImageView *articleImage;
@property (copy, nonatomic) void(^failureBlock)(void);

- (NSString *)stringByStrippingHTML:(NSString *)inputString;
- (void)populateHotDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
