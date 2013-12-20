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
    
    //searchBar && tableheader
    UISearchBar *theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    [theSearchBar setPlaceholder:@"Search"];
    [theSearchBar setShowsCancelButton:YES animated:YES];
    [theSearchBar setKeyboardType:UIKeyboardTypeWebSearch];
    theSearchBar.delegate = self;
    self.tableView.tableHeaderView = theSearchBar;
    
    //table footer
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.tableView.frame.size.width, 44)];
    UILabel *footerLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.tableView.frame.size.width, 44)];
    footerLabel.text = @"上拉显示更多，Copyright © 2013-2020 by IELTSEYE. All Rights Reserved.";
    footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    footerLabel.numberOfLines = 0;
    [footerView addSubview:footerLabel];
    self.tableView.tableFooterView = footerView;
    
    //get data
    [self getNewest];
    
    //pull-to-refesh
    __weak IEMainViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
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
    
    NSString *api = [NSString stringWithFormat:@"http://www.ieltseye.com/ieltsApi/index?page=%d&keyword=%@", page, self.keyword];
    NSLog(@"%@", api);
    NSURL *URL = [NSURL URLWithString:api];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:nil];
    [operation start];
    [operation waitUntilFinished];
    [hud hide:YES];
    self.tableData  = [[operation responseObject] objectForKey:@"datas"];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
//    [self.tableView triggerPullToRefresh];
}


//pull up refresh
- (void)insertRowAtTop {
    self.pageNumber = 1;
    __weak IEMainViewController *weakSelf = self;
    
    NSString *api = [NSString stringWithFormat:@"http://www.ieltseye.com/ieltsApi/index?page=%d", self.pageNumber];
    NSURL *URL = [NSURL URLWithString:api];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
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
    
    if (maximumOffset - currentOffset <= -40) {
        self.pageNumber += 1;
        NSLog(@"%d", self.pageNumber);
        [self getData:self.pageNumber];
    }
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    return 200;
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
