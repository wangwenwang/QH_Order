//
//  GetAppOutPutListViewController.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetAppOutPutListViewController.h"
#import "GetAppOutPutListService.h"
#import "GetOupputListModel.h"
#import "GetOupputListTableViewCell.h"
#import <MBProgressHUD.h>
#import "UITableView+NoDataPrompt.h"
#import "Tools.h"
#import "GetOupputInfoViewController.h"
#import <MJRefresh.h>
#import "AppDelegate.h"
#import "YCXMenu.h"
#import "CondTableViewCell.h"
#import "CustomerListViewController.h"
#import "CondModel.h"
#import "LMPickerView.h"

@interface GetAppOutPutListViewController ()<GetAppOutPutListServiceDelegate, CondTableViewCellDelegate, UISearchBarDelegate, LMPickerViewDelegate>

@property (strong, nonatomic) NSArray *menuTexts;


// 出库列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 网络层
@property (strong, nonatomic) GetAppOutPutListService *service;

// 出库
@property (strong, nonatomic) GetOupputListModel *getOupputListM;

@property (strong, nonatomic) AppDelegate *app;

// 客户代码
@property (strong, nonatomic) NSString *cond_PartyCode;

// 客户名称
@property (strong, nonatomic) NSString *cond_PartyName;

// 订单号
@property (strong, nonatomic) NSString *cond_OrderNo;

// 开始时间
@property (strong, nonatomic) NSString *cond_StartTime;

// 结束时间
@property (strong, nonatomic) NSString *cond_EndTime;

// 条件列表
@property (weak, nonatomic) IBOutlet UITableView *tableView_cond;

// 条件列表高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight_cond;

// 条件数据
@property (strong, nonatomic) NSMutableArray *conds;

// 时间选择
@property (strong, nonatomic) LMPickerView *LM;

// 时间格式
@property (strong, nonatomic) NSDateFormatter *formatter;

// 当前时间类型
@property (copy, nonatomic) NSString *CurrTimeType;

@end

#define kCellHeight_Cond 30

#define kCellName_Cond @"CondTableViewCell"

#define kCellHeight_OupputList 103

#define kCellName_OupputList @"GetOupputListTableViewCell"

#define kCond_PARTY_NAME @"客户名称"

#define kCond_ORDER_NO @"订单号"

#define kCond_START_TIME @"开始时间"

#define kCond_END_TIME @"结束时间"

@implementation GetAppOutPutListViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[GetAppOutPutListService alloc] init];
        _service.delegate = self;
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        _cond_PartyCode = @"";
        _cond_PartyName = @"";
        _cond_OrderNo = @"";
        _cond_StartTime = @"";
        _cond_EndTime = @"";
        
        _conds = [[NSMutableArray alloc] init];
        
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
        
        _LM = [[LMPickerView alloc] init];
        _LM.delegate = self;
        [_LM initDatePicker];
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"订单查询";
    
    // 注册Cell
    [self registerCell];
    
    // 请求列表数据
    [self requstData];
    
    [self addRightBtn];
    
    [self addNotification];
    
    [self addTableViewSearch];
}


- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    if(_conds.count == 0) {
        
        _tableViewHeight_cond.constant = 0;
    }else {
        
        _tableViewHeight_cond.constant = kCellHeight_Cond * _conds.count;
    }
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    [self removeNotification];
}


#pragma mark - 功能函数


// 注册Cell
- (void)registerCell {
    
    [_tableView registerNib:[UINib nibWithNibName:kCellName_OupputList bundle:nil] forCellReuseIdentifier:kCellName_OupputList];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView_cond registerNib:[UINib nibWithNibName:kCellName_Cond bundle:nil] forCellReuseIdentifier:kCellName_Cond];
    _tableView_cond.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)requstData {
    
    NSLog(@"----------show");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service GetAppOutPutList:_app.business.BUSINESS_IDX andADD_USER:_app.user.IDX andStrPage:1 andStrPageCount:9999 andStrPartyCode:_cond_PartyCode andStrPartyName:_cond_PartyName andStrOrdNo:_cond_OrderNo andStrStartTime:_cond_StartTime andStrEndTime:_cond_EndTime];
}

- (void)addRightBtn {
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"条件筛选" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnOnclick)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}


- (void)rightBtnOnclick {
    
    NSArray *items = @[
                       [YCXMenuItem menuItem:@"客户名称"
                                       image:nil
                                         tag:100
                                    userInfo:nil],
                       [YCXMenuItem menuItem:@"开始时间"
                                       image:nil
                                         tag:101
                                    userInfo:nil],
                       [YCXMenuItem menuItem:@"结束时间"
                                       image:nil
                                         tag:102
                                    userInfo:nil]
                       ];
    [YCXMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 50, 0, 50, 0) menuItems:items selected:^(NSInteger index, YCXMenuItem *item) {
        
        if(item.tag == 100) {
            
            CustomerListViewController *vc = [[CustomerListViewController alloc] init];
            vc.vcClass = NSStringFromClass([self class]);
            [self.navigationController pushViewController:vc animated:YES];
        }else if(item.tag == 101) {
            
            _CurrTimeType = kCond_START_TIME;
            [_LM showDatePicker];
        }else if(item.tag == 102) {
            
            _CurrTimeType = kCond_END_TIME;
            [_LM showDatePicker];
        }
    }];
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
    [searchBar setPlaceholder:@"订单号"];
    searchBar.delegate = self;
}

#pragma mark - 通知

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePartyInfo:) name:kGetTmsOrderByAddressViewController_refreshList object:nil];
}

- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetTmsOrderByAddressViewController_refreshList object:nil];
}

- (void)receivePartyInfo:(NSNotification *)aNotify {
    
    _cond_PartyName = aNotify.userInfo[@"PARTY_NAME"];
    _cond_PartyCode = aNotify.userInfo[@"PARTY_CODE"];
    
    [self requstData];
    
    // 删除相同的条件类型
    for (CondModel *c in _conds) {
        if([c.type isEqualToString:kCond_PARTY_NAME]) {
            [_conds removeObject:c];
        }
    }
    
    CondModel *c = [[CondModel alloc] init];
    c.name = _cond_PartyName;
    c.type = kCond_PARTY_NAME;
    [_conds addObject:c];
    [_tableView_cond reloadData];
    [self updateViewConstraints];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView.tag == 1001) {
        
        return _conds.count;
    }else if(tableView.tag == 1002) {
        
        return _getOupputListM.getOupputModel.count;
    }else {
        
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        return kCellHeight_Cond;
    }else if(tableView.tag == 1002) {
        
        GetOupputModel *getOupputM = _getOupputListM.getOupputModel[indexPath.row];
        return getOupputM.cellHeight;
    }else {
        
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        // 处理界面
        static NSString *cellId = kCellName_Cond;
        CondTableViewCell *cell = (CondTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.delegate = self;
        cell.tag = indexPath.row;
        
        CondModel *c = _conds[indexPath.row];
        cell.name.text = c.name;
        
        return cell;
    }else if(tableView.tag == 1002) {
        
        // 处理界面
        static NSString *cellId = kCellName_OupputList;
        GetOupputListTableViewCell *cell = (GetOupputListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        GetOupputModel *getOupputM = _getOupputListM.getOupputModel[indexPath.row];
        
        cell.getOupputM = getOupputM;
        
        return cell;
    }else {
        
        return [[UITableViewCell alloc] init];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GetOupputModel *m = _getOupputListM.getOupputModel[indexPath.row];
    
    GetOupputInfoViewController *vc = [[GetOupputInfoViewController alloc] init];
    vc.oupputM = m;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Store_GetOupputListServiceDelegate

- (void)successOfGetAppOutPutList:(GetOupputListModel *)getOupputListM {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"----------hide");
    
    _getOupputListM = getOupputListM;
    
    for (GetOupputModel *m in _getOupputListM.getOupputModel) {
        
        // 单行高度
        CGFloat oneLine = [Tools getHeightOfString:@"fds" fontSize:13 andWidth:ScreenWidth];
        
        CGFloat PARTY_NAME_height = [Tools getHeightOfString:m.pARTYNAME fontSize:13 andWidth:(ScreenWidth - 8 - 61 - 3)];
        
        CGFloat oneCellHeight = 0;
        if(PARTY_NAME_height > oneLine) {
            
            oneCellHeight = kCellHeight_OupputList + PARTY_NAME_height - oneLine;
        } else {
            
            oneCellHeight = kCellHeight_OupputList;
        }
        
        m.cellHeight = oneCellHeight;
    }
    
    [_tableView removeNoOrderPrompt];
    
    [_tableView reloadData];
}


- (void)successOfGetAppOutPutList_NoData {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"----------hide");
    [_tableView noData:@"您还没有出库单哦" andImageName:LM_NoResult_noOrder];
    
    _getOupputListM = nil;
    [_tableView  reloadData];
}


- (void)failureOfGetAppOutPutList:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"----------hide");
    
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取出库列表失败"];
}

#pragma mark - CondTableViewCellDelegate

- (void)delOnclickOfCondTableViewCell:(NSUInteger)row {
    
    CondModel *c = _conds[row];
    if([c.type isEqualToString:kCond_PARTY_NAME]) {
        
        _cond_PartyName = @"";
        _cond_PartyCode = @"";
    }else if([c.type isEqualToString:kCond_ORDER_NO]) {
        
        _cond_OrderNo = @"";
    }else if([c.type isEqualToString:kCond_START_TIME] || [c.type isEqualToString:kCond_END_TIME]) {
        
        _cond_StartTime = @"";
        _cond_EndTime = @"";
    }
    [_conds removeObjectAtIndex:row];
    [_tableView_cond reloadData];
    [self updateViewConstraints];
    [self requstData];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([[searchText trim] isEqualToString:@""]) {
        
         _cond_OrderNo = searchBar.text;
        [self requstData];
        [self.view endEditing:YES];
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    _cond_OrderNo = searchBar.text;
    [self requstData];
    [self.view endEditing:YES];
}


#pragma mark - LMPickerViewDelegate

- (void)PickerViewComplete:(NSDate *)date {
    
    CondModel *c = [[CondModel alloc] init];
    c.type = _CurrTimeType;
    if([_CurrTimeType isEqualToString:kCond_START_TIME]) {
        
        _cond_StartTime = [_formatter stringFromDate:date];
        if([_cond_EndTime isEqualToString:@""]) {
            
            c.name = [NSString stringWithFormat:@"%@  一  至今", _cond_StartTime];
        }else {
            
            c.name = [NSString stringWithFormat:@"%@  一  %@", _cond_StartTime, _cond_EndTime];
        }
    }else if([_CurrTimeType isEqualToString:kCond_END_TIME]) {
        
        _cond_EndTime = [_formatter stringFromDate:date];
        if([_cond_StartTime isEqualToString:@""]) {
            
            c.name = [NSString stringWithFormat:@"1970年  一  %@", _cond_EndTime];
        }else {
            
            c.name = [NSString stringWithFormat:@"%@  一  %@", _cond_StartTime, _cond_EndTime];
        }
    }
    for (CondModel *c in _conds) {
        if([c.type isEqualToString:kCond_START_TIME] || [c.type isEqualToString:kCond_END_TIME]) {
            [_conds removeObject:c];
        }
    }
    [_conds addObject:c];
    [_tableView_cond reloadData];
    [self updateViewConstraints];
    [self requstData];
}

@end
