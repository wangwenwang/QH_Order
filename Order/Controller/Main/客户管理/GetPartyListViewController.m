//
//  GetPartyListViewController.m
//  Order
//
//  Created by 凯东源 on 17/7/13.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "GetPartyListViewController.h"
#import "MakeOrderService.h"
#import <MBProgressHUD.h>
#import "PartyModel.h"
#import "Tools.h"
#import "AddStockViewController.h"
#import "CustomerListSearchResultsViewController.h"
#import "GetStockListViewController.h"
#import "MainViewController.h"
#import "GetFeeListViewController.h"
#import "GetAppBillFeeListViewController.h"
#import "MineViewController.h"
#import "GetPartyListTableViewCell.h"
#import "DeleteAppUserPartyService.h"
#import "AppDelegate.h"
#import "GetPartyListService.h"
#import "EditPartyViewController.h"

// 地址管理
#import "AddressListViewController.h"

// 创建客户
#import "AddPartyViewController.h"

@interface GetPartyListViewController ()<GetPartyListServiceDelegate, GetPartyListTableViewCellDelegate, UIActionSheetDelegate, DeleteAppUserPartyServiceDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 客户资料列表 (已搜索过滤)
@property (strong, nonatomic) NSMutableArray *partysFilter;

// 客户资料列表 (原始)
@property (strong, nonatomic) NSArray *partys_org;

// 网络层
@property (strong, nonatomic) GetPartyListService *service;

// 新建客户
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

// 网络层
@property (strong, nonatomic) DeleteAppUserPartyService *service_delete;

// 全局变量
@property (strong, nonatomic) AppDelegate *app;

// 删除row
@property (assign, nonatomic) NSUInteger deleteRow;

@end

#define kCellHeight 136

#define kCellName @"GetPartyListTableViewCell"

@implementation GetPartyListViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[GetPartyListService alloc] init];
        _service.delegate = self;
        
        _partysFilter = [[NSMutableArray alloc] init];
        
        _service_delete = [[DeleteAppUserPartyService alloc] init];
        _service_delete.delegate = self;
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"客户列表";
    
    [_addBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    [_addBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    _addBtn.layer.cornerRadius = 20;
    _addBtn.layer.shadowOffset =  CGSizeMake(0, 3);
    _addBtn.layer.shadowOpacity = 0.5;
    _addBtn.layer.shadowColor =  [UIColor redColor].CGColor;
    
    [self addNotification];
    
    [self registerCell];
    
    [self addTableViewSearch];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service GetPartyListByUserIdx:_app.user.IDX andStrBusinessId:_app.business.BUSINESS_IDX];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    NSLog(@"vc dealloc");
    [self removeNotification];
}


#pragma mark - 通知

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMsg:) name:kGetPartyListViewController_receiveMsg object:nil];
}


- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetPartyListViewController_receiveMsg object:nil];
}


- (void)receiveMsg:(NSNotification *)aNotify {
    
//    NSString *msg = aNotify.userInfo[@"msg"];
    
    [_service GetPartyListByUserIdx:_app.user.IDX andStrBusinessId:_app.business.BUSINESS_IDX];
}

#pragma mark - 功能函数

- (void)registerCell {
    
    [_tableView registerNib:[UINib nibWithNibName:kCellName bundle:nil] forCellReuseIdentifier:kCellName];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)pushEdit:(NSUInteger)row {
    
    PartyModel *partyM = _partysFilter[row];
    EditPartyViewController *vc = [[EditPartyViewController alloc] init];
    vc.partyM = partyM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addTableViewSearch {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
    searchBar.backgroundImage = [[UIImage alloc] init];
    searchBar.barTintColor = [UIColor clearColor];
    
    UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    searchField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [view addSubview:searchBar];
    _tableView.tableHeaderView = view;
    [searchBar setPlaceholder:@"按客户名称搜索"];
    searchBar.delegate = self;
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _partysFilter.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = kCellName;
    
    GetPartyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    cell.delegate = self;
    
    cell.tag = indexPath.row;
    
    PartyModel *m = _partysFilter[indexPath.row];
    
    cell.partyM = m;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self pushEdit:indexPath.row];
    
//    PartyModel *party = _partysFilter[indexPath.row];
//    
//    AddressListViewController *vc = [[AddressListViewController alloc] init];
//    vc.party = party;
//    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - GetPartyListServiceDelegate

- (void)successOfGetPartyList:(NSArray *)partys {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    _partysFilter = [partys mutableCopy];
    _partys_org = partys;
    [_tableView reloadData];
}


- (void)failureOfGetPartyList:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
}


#pragma mark - GetPartyListTableViewCellDelegate

- (void)editOnclick:(NSUInteger)row {
    
    [self pushEdit:row];
    
//    if(_partys_org.count == 1) {
//
//        [Tools showAlert:self.view andTitle:@"不能删除，帐号至少需要一个客户"];
//        return;
//    }
//
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"是否确认删除该客户" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
//    sheet.tag = row;
//    [sheet showInView:self.view];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"%ld",buttonIndex);
    
    if(buttonIndex == 0) {
        
        PartyModel *m = _partysFilter[actionSheet.tag];
        
        [_service_delete DeleteAppUserParty:_app.user.IDX andstrPartyId:m.IDX];
        
        _deleteRow = actionSheet.tag;
    }
}


- (IBAction)addOnclick {
    
    AddPartyViewController *vc = [[AddPartyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - DeleteAppUserPartyServiceDelegate

- (void)successOfDeleteAppUserParty:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [Tools showAlert:self.view andTitle:msg];
    
    [_partysFilter removeObjectAtIndex:_deleteRow];
    
    [_tableView reloadData];
}


- (void)failureOfDeleteAppUserParty:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [Tools showAlert:self.view andTitle:msg];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"当前文字：%@", searchText);
    
    [_partysFilter removeAllObjects];
    
    if([[searchText trim] isEqualToString:@""]) {
        
        _partysFilter = [_partys_org mutableCopy];
    } else {
        
        for (int i = 0; i < _partys_org.count; i++) {
            
            PartyModel *m = _partys_org[i];
            if([m.PARTY_NAME rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
                
                [_partysFilter addObject:m];
            } else {
                
            }
        }
    }
    [_tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.view endEditing:YES];
}

@end
