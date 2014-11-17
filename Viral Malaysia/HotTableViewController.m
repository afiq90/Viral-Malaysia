//
//  HotTableViewController.m
//  Viral Malaysia
//
//  Created by zer0 on 11/12/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import "HotTableViewController.h"
#import "HotTableViewCell.h"
#import "getData.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "HotViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GADRequest.h"
#import "GADInterstitial.h"
#import "CBStoreHouseRefreshControl.h"

#define ViralNewsPostRecent @"http://fastviralnews.com/?json=get_posts_recent"
#define interstitialAdUnitID @"ca-app-pub-8582584431754214/5505035885"
#define bannerAdUnitID @"ca-app-pub-8582584431754214/5365435080"


@interface HotTableViewController () <GADInterstitialDelegate>
@property (nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSArray *articleArray;
@property (strong, nonatomic) NSArray *latestArticleArray;
@property (nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) NSString *dataFilePath;
@property (nonatomic) MBProgressHUD *progressHUD;
@property (nonatomic) GADInterstitial *interstitial;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) CBStoreHouseRefreshControl *storeHouseRefreshControl;
@end

@implementation HotTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // JSON URL For Category http://fastviralnews.com/?json=get_category_posts&slug=gosip
    // JSON URL For Search http://fastviralnews.com/?json=get_search_results&search=%22iggy%22
    
    [self loadInterstitialAds];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Specify the data storage file path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *docDictionary = [paths objectAtIndex:0];
    _dataFilePath = [docDictionary stringByAppendingPathComponent:@"ViralNewsHotData"];
    
    // Load saved data from file
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataFilePath]) {
        _articleArray = [NSArray arrayWithContentsOfFile:self.dataFilePath];
        [self.tableView reloadData];
    }
    
    // UIRefreshControl Stuff
    _refresh = [[UIRefreshControl alloc] init];
    [_refresh addTarget:self action:@selector(populateHotData) forControlEvents:UIControlEventValueChanged];
    [_refresh beginRefreshing];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:m"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *lastUpdate = [NSString stringWithFormat:@"Last Update On %@:", dateString];
    _refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
    [self setRefreshControl:_refresh];

//    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(populateHotData) plist:@"storehouse"];


    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self populateHotDataWithCompletionHandler:nil];
    
    // MBProgressHUD Stuff
    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHUD.mode = MBProgressHUDAnimationFade;
    _progressHUD.labelText = @"Loading...";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Hot Article With Completion Handler

- (void)populateHotDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *urlString = ViralNewsPostRecent;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            _articleArray = [[NSArray alloc] init];
            _articleArray = [json valueForKeyPath:@"posts"];
            
            _latestArticleArray = [json valueForKeyPath:@"posts"];
            NSDictionary *latestDataDic = [_latestArticleArray objectAtIndex:0];
            NSString *latestTitle = latestDataDic[@"title"];
           // NSLog(@"latest title : %@", latestTitle);
            
            NSDictionary *existingDataDict = [self.articleArray objectAtIndex:0];
            NSString *existingTitle = [existingDataDict objectForKey:@"title"];
            //NSLog(@"existing title : %@", existingTitle);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [_refresh endRefreshing];
                 //[self.storeHouseRefreshControl finishingLoading];
                
                // Hide MBProgressHUD
                [_progressHUD hide:YES];
                
                // CompletionHandler Stuff
                if (completionHandler) {
                    if ([latestTitle isEqual:existingTitle]) {
                        completionHandler(UIBackgroundFetchResultNewData);
                       // [UIApplication sharedApplication].applicationIconBadgeNumber++;
                } else {
                    
                    if (![_articleArray writeToFile:self.dataFilePath atomically:YES]) {
                        NSLog(@"Couldn't save data.");
                    }
                    completionHandler(UIBackgroundFetchResultNoData);
                  }
                }
            });

        } else {
            __weak HotTableViewController *weakself = self;
            [self setFailureBlock:^{
                if (completionHandler) {
                    completionHandler(UIBackgroundFetchResultFailed); }
                [weakself.refresh endRefreshing];
                //[weakself.storeHouseRefreshControl finishingLoading];
            }];
            
           // completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
    
    [dataTask resume];
}

#pragma mark - Get Hot article without completion Handler

- (void)populateHotData {
    
    NSString *urlString = ViralNewsPostRecent;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            _articleArray = [[NSArray alloc] init];
            _articleArray = [json valueForKeyPath:@"posts"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [_refresh endRefreshing];
               // [self.storeHouseRefreshControl finishingLoading];

                // Hide MBProgressHUD
                [_progressHUD hide:YES];
            });
        }
    }];
    
    [dataTask resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _articleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...

    HotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    NSDictionary *dataFromJSON = _articleArray[indexPath.row];
    
    NSMutableDictionary *response = [[[dataFromJSON valueForKey:@"categories"]  objectAtIndex:0] mutableCopy];
    NSString *category = [response valueForKey:@"title"];
//    NSLog(@"categoriesxx : %@", category);
    cell.categoryLabel.text = category;

    //  Get the imageString and URL then set it to SDWebImage. SDWebImage will cache the image.
    
    NSString *imageString = [dataFromJSON valueForKeyPath:@"thumbnail_images.full.url"];
    NSURL *URL = [NSURL URLWithString:imageString];
    [cell.imageVIew sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    cell.titleLabel.text = dataFromJSON[@"title"];
    NSString *excerpt = [self stringByStrippingHTML:dataFromJSON[@"excerpt"]];
    cell.contentLabel.text = excerpt;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate 

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.storeHouseRefreshControl scrollViewDidScroll];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [self.storeHouseRefreshControl scrollViewDidEndDragging];
//}

#pragma mark - Helper Methods


// Remove the html tag from NSString
- (NSString *)stringByStrippingHTML:(NSString *)inputString
{
    NSMutableString *outString;
    
    if (inputString)
    {
        outString = [[NSMutableString alloc] initWithString:inputString];
        
        if ([inputString length] > 0)
        {
            NSRange r;
            
            while ((r = [outString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
            {
                [outString deleteCharactersInRange:r];
            }      
        }
    }
    
    return outString; 
}

// GADInterstitial Stuff

-(void) loadInterstitialAds {
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.adUnitID = interstitialAdUnitID;
    self.interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    //request.testDevices = @[@"4ac809b51e2ce29cb21c6b8598e355f2"];
    [self.interstitial loadRequest:request];

    // Assumes an image named "SplashImage" exists.
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage  imageNamed:@"SplashImage"]];
    self.imageView.frame = self.view.frame;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.imageView];
}

#pragma mark - GADInterstitial Delegate

// Show the ads when receive the ads from google
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    [self.interstitial presentFromRootViewController:self];
}

// remove imageview when the ads failed to connect
- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.imageView removeFromSuperview];
}

// remove imageview when the ads dismissed
- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial {
    [self.imageView removeFromSuperview];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].

    if ([segue.identifier isEqual:@"HotDetailVC"]) {
        // Pass the selected object to the new view controller.
        HotViewController *hotVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *linkToPass = _articleArray[indexPath.row];
        hotVC.link = linkToPass[@"url"];
        hotVC.shareTitle = linkToPass[@"title"];
    }
    
    
    
}


@end
