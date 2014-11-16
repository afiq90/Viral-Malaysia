//
//  TrendingViewController.h
//  Viral Malaysia
//
//  Created by zer0 on 11/12/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *trendingWebView;
@property (nonatomic) NSString *link;
@property (nonatomic) NSString *shareTitle;
@end
