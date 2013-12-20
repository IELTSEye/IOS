//
//  IEMainViewController.h
//  IETSEYE
//
//  Created by WillLee on 13-12-18.
//  Copyright (c) 2013年 WillLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
@interface IEMainViewController : UITableViewController <UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate>{
    GADBannerView *adMobBanner_;
}

@property(strong, nonatomic)NSMutableArray *tableData;
@property(strong, nonatomic)UISearchBar *tweetsSearchBar;
@property  NSInteger pageNumber;
@property NSString *keyword;
@end

