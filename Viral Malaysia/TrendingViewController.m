//
//  TrendingViewController.m
//  Viral Malaysia
//
//  Created by zer0 on 11/12/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import "TrendingViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface TrendingViewController ()
@property (nonatomic) MBProgressHUD *progressHUD;
@end

@implementation TrendingViewController

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    // MBProgressHUD Stuff
//    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
//    _progressHUD.labelText = @"Loading Article...";
    
    // Set the delegate for webview
    self.trendingWebView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:self.link];
    if (url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.trendingWebView loadRequest:request];
            
        });
    }
    
    //NSLog(@"trending url : %@", url);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web View Delegate

-(void)webViewDidStartLoad:(UIWebView *)webView {
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
   // [_progressHUD hide:YES];
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Social Share Button

- (IBAction)socialShareButton:(id)sender {
    
    NSString *test = [NSString stringWithFormat:@"@viralmalaysia %@, %@", self.shareTitle, self.link];
    NSArray *arr = [NSArray arrayWithObject:test];
    UIActivityViewController *socialShare = [[UIActivityViewController alloc] initWithActivityItems:arr applicationActivities:nil];
    socialShare.excludedActivityTypes = @[UIActivityTypePostToFlickr,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypePostToTencentWeibo,UIActivityTypeCopyToPasteboard];
    [self presentViewController:socialShare animated:YES completion:nil];
    
}

@end