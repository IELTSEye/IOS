//
//  WeiboCell.m
//  IETSEYE
//
//  Created by WillLee on 13-12-19.
//  Copyright (c) 2013年 WillLee. All rights reserved.
//

#import "WeiboCell.h"
#import "Weibo.h"
@implementation WeiboCell

@synthesize Weibo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier weibo:(Weibo *) Weibo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.Weibo = Weibo;
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(0, 0, self.frame.size.width, 20.0f);
        [nameLabel setTextColor:[UIColor blackColor]];
        [nameLabel setText:Weibo.username];
        [self.contentView addSubview:nameLabel];
        
        
        UILabel *contentLabel = [[UILabel alloc] init];
        //    CGSize labelSize = [Weibo.content sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]
        //                       constrainedToSize:CGSizeMake(self.frame.size.width, 100)
        //                           lineBreakMode:NSLineBreakByWordWrapping];
        contentLabel.frame = CGRectMake(0, 30.0f, self.frame.size.width, 100.0f);
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.numberOfLines = 0;
        contentLabel.text = Weibo.content;
        [contentLabel sizeToFit];
        [self.contentView addSubview:contentLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
