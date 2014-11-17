//
//  VideoTableViewCell.h
//  Viral Malaysia
//
//  Created by zer0 on 11/17/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageview;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;

@end
