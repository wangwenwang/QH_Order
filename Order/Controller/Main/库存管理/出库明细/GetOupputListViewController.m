//
//  GetOupputListViewController.m
//  Order
//
//  Created by 凯东源 on 2017/8/18.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "GetOupputListViewController.h"
#import "Store_GetOupputListService.h"
#import "GetOupputListModel.h"
#import "GetOupputListTableViewCell.h"
#import <MBProgressHUD.h>
#import "UITableView+NoDataPrompt.h"
#import "Tools.h"
#import "GetOupputInfoViewController.h"
#import <MJRefresh.h>
#import "AppDelegate.h"
#import <Masonry.h>
#import "MergeOutputOrderService.h"

@interface GetOupputListViewController ()<Store_GetOupputListServiceDelegate, MergeOutputOrderServiceDelegate>

@property (strong, nonatomic) NSArray *menuTexts;


// 出库列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 网络层
@property (strong, nonatomic) Store_GetOupputListService *service;

// 出库
@property (strong, nonatomic) GetOupputListModel *getOupputListM;

// 全局变量
@property (strong, nonatomic) AppDelegate *app;

// 右上角按钮iselected
@property (assign, nonatomic) BOOL rightIselected;

// 底部确定按钮，多选合并出库单时用
@property (strong, nonatomic) UIView *bottomBtnContainerView;

// 合并出库单，生成采购单
@property (strong, nonatomic) MergeOutputOrderService *service_merge;

@end

#define kCellHeight 146

#define kCellName @"GetOupputListTableViewCell"

@implementation GetOupputListViewController


- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[Store_GetOupputListService alloc] init];
        _service.delegate = self;
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        _service_merge = [[MergeOutputOrderService alloc] init];
        _service_merge.delegate = self;
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"出库明细";
    
    // 注册Cell
    [self registerCell];
    
//    [self addRightBtn];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service GetOupputList:_addressM.IDX andstrPage:1 andstrPageCount:9999 andBUSINESS_IDX:_app.business.BUSINESS_IDX];
    
    // 下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataDown)];
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    _tableView.mj_header = header;
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if(_refreshList) {
        
        [_tableView.mj_header beginRefreshingWithCompletionBlock:nil];
    }
}


- (void)loadMoreDataDown {
    
    if([Tools isConnectionAvailable]) {
        
        [_service GetOupputList:_addressM.IDX andstrPage:1 andstrPageCount:9999 andBUSINESS_IDX:_app.business.BUSINESS_IDX];
    } else {
        
        [Tools showAlert:self.view andTitle:@"网络连接不可用"];
    }
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - 功能函数


// 注册Cell
- (void)registerCell {
    
    [_tableView registerNib:[UINib nibWithNibName:kCellName bundle:nil] forCellReuseIdentifier:kCellName];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)addRightBtn {
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"生成采购单" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnOnclick)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}


- (void)addCancelRightBtn {
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnOnclick)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}


- (UIView *)bottomBtnContainerView {
    
    if(_bottomBtnContainerView == nil) {
        
        _bottomBtnContainerView = [[UIView alloc] init];
        [self.view addSubview:_bottomBtnContainerView];
        [_bottomBtnContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.left.mas_equalTo(40);
            make.right.mas_equalTo(-40);
            make.bottom.mas_equalTo(-SafeAreaBottomHeight);
        }];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        UIButton *confirmBtn = [[UIButton alloc] init];
        [_bottomBtnContainerView addSubview:cancelBtn];
        [_bottomBtnContainerView addSubview:confirmBtn];
        
        [cancelBtn.layer setCornerRadius:5.0];
        [cancelBtn addTarget:self action:@selector(cancelMerOrder) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [cancelBtn setBackgroundImage:[Tools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[Tools createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
        cancelBtn.clipsToBounds = YES;
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(confirmBtn.mas_left).offset(-40);
            make.bottom.mas_equalTo(0);
        }];
        
        [confirmBtn.layer setCornerRadius:5.0];
        [confirmBtn addTarget:self action:@selector(merOrder) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [confirmBtn setBackgroundImage:[Tools createImageWithColor:RGB(38, 135, 250)] forState:UIControlStateNormal];
        [confirmBtn setBackgroundImage:[Tools createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
        confirmBtn.clipsToBounds = YES;
        [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(cancelBtn.mas_right).offset(40);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(cancelBtn.mas_width);
        }];
    }
    return _bottomBtnContainerView;
}


#pragma mark - 事件

- (void)rightBtnOnclick {
    
    _rightIselected = !_rightIselected;
    [_tableView reloadData];
    
    [self bottomBtnContainerView];
    [self.view layoutIfNeeded];
    
    if(_rightIselected) {
        
        [self.bottomBtnContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(43);
        }];
        [self addCancelRightBtn];
    }else {
        
        [self.bottomBtnContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self addRightBtn];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.view layoutIfNeeded];
    }];
}


- (void)cancelMerOrder {
    
    [self rightBtnOnclick];
}


- (void)merOrder {
    
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    for (GetOupputModel *m in _getOupputListM.getOupputModel) {
        
        if(m.cellSelected) {
            
            [orders addObject:m];
        }
    }
    
    if(orders.count <= 0) {
        
        [Tools showAlert:self.view andTitle:@"未选中任何订单"];
    }else {
        
        NSString *orderNos = @"";
        for (GetOupputModel *m in orders) {
            
            orderNos = [NSString stringWithFormat:@"%@%@,", orderNos, m.oUTPUTNO];
        }
        orderNos = [orderNos substringToIndex:orderNos.length - 1];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_service_merge mergeOutputOrder:orderNos];
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _getOupputListM.getOupputModel.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GetOupputModel *getOupputM = _getOupputListM.getOupputModel[indexPath.row];
    
    return getOupputM.cellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 处理界面
    static NSString *cellId = kCellName;
    GetOupputListTableViewCell *cell = (GetOupputListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    GetOupputModel *getOupputM = _getOupputListM.getOupputModel[indexPath.row];
    
    cell.getOupputM = getOupputM;
    cell.isEnableMul = _rightIselected;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GetOupputModel *m = _getOupputListM.getOupputModel[indexPath.row];
    
    if(_rightIselected) {
        
        m.cellSelected = !m.cellSelected;
        [_tableView reloadData];
    }else {
        
        GetOupputInfoViewController *vc = [[GetOupputInfoViewController alloc] init];
        vc.oupputM = m;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Store_GetOupputListServiceDelegate

- (void)successOfGetOupputList:(GetOupputListModel *)getOupputListM {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView.mj_header endRefreshing];
    _refreshList = NO;
    
    _getOupputListM = getOupputListM;
    
    for (GetOupputModel *m in _getOupputListM.getOupputModel) {
        
        // 单行高度
        CGFloat oneLine = [Tools getHeightOfString:@"fds" fontSize:13 andWidth:ScreenWidth];
        
        CGFloat PARTY_NAME_height = [Tools getHeightOfString:m.pARTYNAME fontSize:13 andWidth:(ScreenWidth - 8 - 61 - 3)];
        
        CGFloat oneCellHeight = 0;
        if(PARTY_NAME_height > oneLine) {
            
            oneCellHeight = kCellHeight + PARTY_NAME_height - oneLine;
        } else {
            
            oneCellHeight = kCellHeight;
        }
        
        m.cellHeight = oneCellHeight;
    }
    
    [_tableView removeNoOrderPrompt];
    
    [_tableView reloadData];
}


- (void)successOfGetOupputList_NoData {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView.mj_header endRefreshing];
    
    [_tableView noData:@"您还没有出库明细" andImageName:LM_NoResult_noOrder];
}


- (void)failureOfGetOupputList:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView.mj_header endRefreshing];
    
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取出库列表失败"];
}


#pragma mark - MergeOutputOrderServiceDelegate

- (void)successOfMergeOutputOrder {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView.mj_header beginRefreshingWithCompletionBlock:nil];
}


- (void)failureOfMergeOutputOrder:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [Tools showAlert:self.view andTitle:msg];
    [_tableView.mj_header beginRefreshingWithCompletionBlock:nil];
    [self rightBtnOnclick];
}

@end
