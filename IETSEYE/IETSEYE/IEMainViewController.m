//
//  IEMainViewController.m
//  IETSEYE
//
//  Created by WillLee on 13-12-18.
//  Copyright (c) 2013年 WillLee. All rights reserved.
//

#import "IEMainViewController.h"
#import "DDLog.h"
#import "AFNetworking.h"
#import "SBJson.h"
#import "WeiboCell.h"
#import "Weibo.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
//google admob
#define MY_BANNER_UNIT_ID @"a151ea648108251"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface IEMainViewController ()

@end

@implementation IEMainViewController

@synthesize tableData;
@synthesize pageNumber;
@synthesize keyword;
@synthesize tweetsSearchBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(getNewest)];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(openHomePage)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.title = @"@雅思口语网蹲哥";

    self.tableData = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.keyword = @"";
    [self.tableView.tableHeaderView setHidden:NO];
    [self.tableView setAlwaysBounceVertical:YES];
    
    //searchBar && tableheader
    
    tweetsSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    [tweetsSearchBar setPlaceholder:@"Search"];
    [tweetsSearchBar setShowsCancelButton:YES animated:YES];
    [tweetsSearchBar setKeyboardType:UIKeyboardTypeWebSearch];
    tweetsSearchBar.delegate = self;
    
    
    //table footer
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 104)];
    UILabel *footerSummary =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    footerSummary.text = @"Drag to load more...";
    footerSummary.textColor = [UIColor grayColor];
    footerSummary.font = [UIFont fontWithName:@"Chalkduster" size:15];
    footerSummary.textAlignment = NSTextAlignmentCenter;
    
    UILabel *footerLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.tableView.frame.size.width, 60)];
    footerLabel.text = @"Copyright © 2013-2020 by IELTSEYE. All Rights Reserved.";
    footerLabel.textColor = [UIColor grayColor];
    footerLabel.font = [UIFont fontWithName:@"Chalkduster" size:10];
    footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    footerLabel.numberOfLines = 0;
    footerLabel.textAlignment = NSTextAlignmentCenter;

    [footerView addSubview:footerSummary];
    [footerView addSubview:footerLabel];

    self.tableView.tableFooterView = footerView;
    
    //get data
    [self getNewest];
    
    
    
    
    
//    google admob
    
    adMobBanner_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    adMobBanner_.adUnitID           = MY_BANNER_UNIT_ID;
    adMobBanner_.rootViewController = self;
    [adMobBanner_ loadRequest:[GADRequest request]];
    
    
    
    
    //pull-to-refesh
//    __weak IEMainViewController *weakSelf = self;
    
    // setup pull-to-refresh
//    [self.tableView addPullToRefreshWithActionHandler:^{
//        [weakSelf insertRowAtTop];
//    }];
    
}

- (void) openHomePage{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ieltseye.com"]];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.pageNumber = 1;
    self.keyword = searchBar.text;
    NSLog(@"%@", self.keyword);
    [searchBar resignFirstResponder];
    [self getData:self.pageNumber];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Clear the search text
    // Deactivate the UISearchBar
    searchBar.text=@"";
    [searchBar resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeiboCell";
    WeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WeiboCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *weiboData = [self.tableData objectAtIndex:indexPath.row];
    
    Weibo *WeiboItem = [[Weibo alloc] init];
    WeiboItem.uid = weiboData[@"uid"];
    WeiboItem.username = weiboData[@"screen_name"];
    WeiboItem.created_at = weiboData[@"created_at"];
    WeiboItem.content = weiboData[@"text"];
    [cell setWeiboObj:WeiboItem];
    
    return cell;
}

- (void)getNewest{
    self.pageNumber = 1;
    self.keyword = @"";
    [self getData:self.pageNumber];
}

//get data function
- (void)getData:(NSInteger )page{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *api = @"http://www.ieltseye.com/ieltsApi/tweets";
    NSDictionary *parameters = @{@"page": [NSString stringWithFormat:@"%d", page], @"keyword":self.keyword};
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod: @"POST" URLString:api parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self scrollToTop];
    } failure:nil];
    [operation start];
    [operation waitUntilFinished];
//    scroll before reload
    [hud hide:YES];
    self.tableData  = [[operation responseObject] objectForKey:@"datas"];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.tableView triggerPullToRefresh];
}


//pull up refresh
- (void)insertRowAtTop {
    self.pageNumber = 1;
    __weak IEMainViewController *weakSelf = self;
    
    NSString *api = @"http://www.ieltseye.com/ieltsApi/tweets";
    NSDictionary *parameters = @{@"page": [NSString stringWithFormat:@"%d", self.pageNumber], @"keyword":self.keyword};
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod: @"POST" URLString:api parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        weakSelf.tableData = [[operation responseObject] objectForKey:@"datas"];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.pullToRefreshView stopAnimating];
    } failure:nil];
    [operation start];
//    [operation waitUntilFinished];
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -20) {
        self.pageNumber += 1;
        NSLog(@"%d", self.pageNumber);
        [self getData:self.pageNumber];
    }
}

-(void) scrollToTop{
    [self.tableView setContentOffset:CGPointMake(0, -70) animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return tweetsSearchBar;
//    self.tableView.tableHeaderView = theSearchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return adMobBanner_;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
