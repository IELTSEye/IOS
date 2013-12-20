//
//  IEMainViewController.h
//  IETSEYE
//
//  Created by WillLee on 13-12-18.
//  Copyright (c) 2013年 WillLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IEMainViewController : UITableViewController <UITableViewDataSource, UISearchBarDelegate>

@property(strong, nonatomic)NSMutableArray *tableData;
@property  NSInteger pageNumber;
@property NSString *keyword;
@end

