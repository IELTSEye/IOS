//
//  WeiboCell.h
//  IETSEYE
//
//  Created by WillLee on 13-12-19.
//  Copyright (c) 2013年 WillLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weibo.h"
@interface WeiboCell : UITableViewCell

@property(nonatomic, retain) UILabel *nameLabel;
@property(nonatomic, retain) UILabel *contentLabel;
@property(nonatomic, retain) UILabel *timeLabel;
@property(nonatomic , retain) Weibo *weiboObj;
@end
