//
//  TrendingTableViewCell.h
//  Viral Malaysia
//
//  Created by zer0 on 11/12/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
