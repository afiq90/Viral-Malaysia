//
//  VideoTVC.m
//  Viral Malaysia
//
//  Created by zer0 on 11/17/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import "VideoTVC.h"
#import "VideoTableViewCell.h"
#import "XCDYouTubeKit.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Reachability.h"
#import <SimpleAudioPlayer/SimpleAudioPlayer.h>

//https://gdata.youtube.com/feeds/api/videos?q=googledevelopers&max-re‌​sults=5&v=2&alt=jsonc&orderby=published
//http://gdata.youtube.com/feeds/api/users/UCvHHSOctV36yg14lDKZhlqg/uploads?alt=json&start-index=1&max-results=2
#define youtubeVideoChannel @"http://gdata.youtube.com/feeds/api/users/UCvHHSOctV36yg14lDKZhlqg/uploads?v=2&alt=jsonc"

@interface VideoTVC ()
{
    NSURLSession *session;
    NSArray *dataArray;
    NSArray *videoArray;
    NSDictionary *videoDict;
    NSArray *thumbnailArray;
    NSDictionary *thumbnailDict;
    NSString *videoID;
    UIRefreshControl *refresh;
    MBProgressHUD *progressHUD;
    Reachability *internetReachableFoo;
}
@end

@implementation VideoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateVideoData];
    
    // UIRefreshControl Stuff
        refresh = [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(populateVideoData) forControlEvents:UIControlEventValueChanged];
        [refresh beginRefreshing];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, h:m"];
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        NSString *lastUpdate = [NSString stringWithFormat:@"Last Update On %@:", dateString];
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
        [self setRefreshControl:refresh];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
        // MBProgressHUD Stuff
        progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.mode = MBProgressHUDAnimationFade;
        progressHUD.labelText = @"Loading...";
    
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

- (void)populateVideoData {
    
    NSString *urlString = youtubeVideoChannel;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            dataArray = [[NSArray alloc] init];
            dataArray = [json valueForKeyPath:@"data.items"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [refresh endRefreshing];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [progressHUD setHidden:YES];
                
                //Play audio fore refresh
                [SimpleAudioPlayer playFile:@"refresh.wav"];
            });
        }
    }];
    
    [dataTask resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return dataArray.count;
    //return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    videoDict = dataArray[indexPath.row];
    NSString *thumbnailString = videoDict[@"thumbnail"][@"hqDefault"];
    NSURL *thumbnailURL = [NSURL URLWithString:thumbnailString];
    NSData *thumbnaildata = [NSData dataWithContentsOfURL:thumbnailURL];
    UIImage *thumbnailImage = [UIImage imageWithData:thumbnaildata];
    cell.thumbnailImageview.image = thumbnailImage;

    cell.titleLabel.text = videoDict[@"title"];
    NSString *duration = [self timeFormatted:[videoDict[@"duration"] intValue]];
    cell.durationLabel.text = duration;
    NSString *viewCount = [NSString stringWithFormat:@"%@ Views", videoDict[@"viewCount"]];
    cell.viewsLabel.text = viewCount;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        NSDictionary *videoDic = dataArray[indexPath.row];
        NSString *videoString = videoDic[@"id"];
        XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoString];
        [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
}

#pragma mark - Helper Methods

// Change second to minute style 02:00

-(NSString*)timeFormatted:(int)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours) {
        return [NSString stringWithFormat:@"%dh:%02dm", hours, minutes];
    }
    return [NSString stringWithFormat:@"%02d:%02d" , minutes, seconds];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
