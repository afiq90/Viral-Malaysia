//
//  TrendingTableViewController.m
//  Viral Malaysia
//
//  Created by zer0 on 11/12/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import "TrendingTableViewController.h"
#import "TrendingTableViewCell.h"
#import "getData.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TrendingViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SimpleAudioPlayer/SimpleAudioPlayer.h>

#define ViralNewsPostTrending @"http://fastviralnews.com/?json=get_category_posts&slug=gosip"


@interface TrendingTableViewController ()
@property (nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSArray *articleArray;
@property (nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) NSString *dataFilePath;
@property (nonatomic) MBProgressHUD *progressHUD;
@end

@implementation TrendingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // JSON URL For category http://fastviralnews.com/?json=get_category_posts&slug=gosip
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    // UIRefreshControl Stuff
    _refresh = [[UIRefreshControl alloc] init];
    [_refresh addTarget:self action:@selector(populateTrendingData) forControlEvents:UIControlEventValueChanged];
    [_refresh beginRefreshing];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:m"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *lastUpdate = [NSString stringWithFormat:@"Last Update On %@:", dateString];
    _refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
    
    [self setRefreshControl:_refresh];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self populateTrendingData];
    
    // MBProgressHUD Stuff
    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHUD.mode = MBProgressHUDAnimationFade;
    _progressHUD.labelText = @"Loading...";
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    [[[self navigationController] navigationBar] setBarTintColor:[UIColor colorWithRed:255/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Trending Article

- (void)populateTrendingData {
    
    NSString *urlString = ViralNewsPostTrending;
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
                
                // Hide MBProgressHUD
                [_progressHUD hide:YES];
                
                //Play audio fore refresh
                [SimpleAudioPlayer playFile:@"refresh.wav"];
            });
        }
    }];
    
    [dataTask resume];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //return _articleArray.count;
    return 7;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    
    TrendingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    NSDictionary *dataFromJSON = _articleArray[indexPath.row];
    
    NSMutableDictionary *response = [[[dataFromJSON valueForKey:@"categories"]  objectAtIndex:0] mutableCopy];
    NSString *category = [response valueForKey:@"title"];
    //    NSLog(@"categoriesxx : %@", category);
    cell.categoryLabel.text = category;
    
    //  Get the imageString and URL then set it to SDWebImage. SDWebImage will cache the image.
    
    NSString *imageString = [dataFromJSON valueForKeyPath:@"thumbnail_images.full.url"];
    NSURL *URL = [NSURL URLWithString:imageString];
    [cell.imageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    cell.titleLabel.text = dataFromJSON[@"title"];
    NSString *excerpt = [self stringByStrippingHTML:dataFromJSON[@"excerpt"]];
    cell.contentLabel.text = excerpt;
    
    return cell;
}

#pragma mark - helper methods


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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqual:@"TrendingDetailVC"]) {
        // Pass the selected object to the new view controller.
        TrendingViewController *trendingVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *linkToPass = _articleArray[indexPath.row];
        trendingVC.link = linkToPass[@"url"];
        trendingVC.shareTitle = linkToPass[@"title"];
    }
}

@end
