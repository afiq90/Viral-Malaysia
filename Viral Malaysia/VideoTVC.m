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

#define youtubeVideoChannel @"http://gdata.youtube.com/feeds/api/users/UCvHHSOctV36yg14lDKZhlqg/uploads?alt=json&max-results=2"

@interface VideoTVC ()
{
    NSURLSession *session;
    NSArray *videoArray;
    NSArray *thumbnailArray;
    NSDictionary *thumbnailDict;
    NSString *videoID;
}
@end

@implementation VideoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self populateHotData];
}

- (void)populateHotData {
    
    NSString *urlString = youtubeVideoChannel;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            videoArray = [[NSArray alloc] init];
            videoArray = [json valueForKeyPath:@"feed"];
            thumbnailArray = [json valueForKeyPath:@"feed.entry.media$group.media$thumbnail"];
//            thumbnailDict = [[thumbnailArray objectAtIndex:0] objectAtIndex:0][@"url"];
            NSLog(@"thumbnail array : %@", thumbnailDict);

            NSString *videoString = [[json valueForKeyPath:@"feed.entry.id.$t"] objectAtIndex:0];
            videoID = [videoString substringFromIndex:42];
            NSLog(@"video ID : %@", videoID);

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
               // [_refresh endRefreshing];
                
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
    return videoArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
    
    
    // Configure the cell...
    //NSString *thumbnailString = thumbnailArray[indexPath.row];
    //NSLog(@"thumbnailzzz : %@", thumbnailString);
//    NSURL *thumbnailURL = [NSURL URLWithString:thumbnailDict];
//    NSData *thumbnaildata = [NSData dataWithContentsOfURL:thumbnailURL];
//    UIImage *thumbnailImage = [UIImage imageWithData:thumbnaildata];
//    cell.thumbnailImageview.image = thumbnailImage;
//    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoID];
    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
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
