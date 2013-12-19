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
@property(nonatomic , retain) Weibo *Weibo;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier weibo:(Weibo *) Weibo;
@end
