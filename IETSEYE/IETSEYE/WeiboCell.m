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

@synthesize weiboObj;

@synthesize nameLabel;
@synthesize contentLabel;
@synthesize timeLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(0, 0, self.frame.size.width, 20.0f);


        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30.0f, self.frame.size.width, 100.0f)];
        timeLabel = [[UILabel alloc] init];
        
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:contentLabel];
        [self.contentView addSubview:timeLabel];
        self.contentView.layer.cornerRadius = 5;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setWeiboObj:(Weibo *)weiboItem{
    weiboObj = weiboItem;
    nameLabel.text = weiboItem.username;
    nameLabel.textColor = [[UIColor alloc] initWithRed:0 green:0.33f blue:0.6f alpha:1];
    nameLabel.backgroundColor = [[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    nameLabel.layer.borderColor = [[UIColor alloc] initWithRed:0.86f green:0.86f blue:0.86f alpha:1].CGColor;
    nameLabel.layer.borderWidth = 0.9;
    nameLabel.layer.cornerRadius = 5;
    
    nameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserWeibo)];
    [nameLabel addGestureRecognizer:tapGesture];
    
    
    contentLabel.text = weiboItem.content;
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contentLabel.numberOfLines = 0;
    [contentLabel sizeToFit];
    [timeLabel setFrame:CGRectMake(0, contentLabel.frame.size.height+30, self.frame.size.width, 20.0f)];
    timeLabel.text = weiboItem.created_at;
    timeLabel.textColor = [UIColor grayColor];
    timeLabel.font = [UIFont fontWithName:@"American Typewriter" size:10];
    
    [self setNeedsDisplay];
}
- (void) openUserWeibo{
    NSString *userPage = [NSString stringWithFormat:@"http://www.weibo.cn/%@", self.weiboObj.uid];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:userPage]];
}

@end
