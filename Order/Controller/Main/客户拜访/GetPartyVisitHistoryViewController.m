//
//  GetPartyVisitHistoryViewController.m
//  Order
//
//  Created by wenwang wang on 2019/3/19.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetPartyVisitHistoryViewController.h"
#import "LLDateFilterView.h"
#import "UIView+LLDateFilterView.h"
#import "GetPartyVisitHistoryTableViewCell.h"
#import "GetPartyVisitListService.h"
#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import "UITableView+NoDataPrompt.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "KBShowStepViewController.h"
#import "TimeLabel.h"
#import "LMBlurredView.h"

// 继续拜访
#import "PartyModel.h"
#import "AddressModel.h"
#import "AddPartyVisitViewController.h"
#import "GetVisitEnterShopViewController.h"
#import "GetVisitCheckInventoryViewController.h"
#import "GetVisitRecommendedOrderViewController.h"
#import "GetVisitVividDisplayViewController.h"

@interface GetPartyVisitHistoryViewController ()<GetPartyVisitListServiceDelegate, UITableViewDataSource, UITableViewDelegate, LMBlurredViewDelegate, GetPartyVisitHistoryTableViewCellDelegate>

@property (nonatomic, strong) LLDateFilterView * dataView;

@property (weak, nonatomic) IBOutlet TimeLabel *resultLabel;

@property (strong, nonatomic) GetPartyVisitListService *service;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) int page;

// 过滤后的TableView数据
@property (strong, nonatomic) NSMutableArray *visitsFilter;

// 全局变量
@property (strong, nonatomic) AppDelegate *app;

// 虚化背景
@property (strong, nonatomic) LMBlurredView *blurredView;

@end

#define kPageCount 20

#define kCellHeight 110

#define kCellName @"GetPartyVisitHistoryTableViewCell"

// 温馨提示
#define kPrompt @"您还没有拜访记录哦"

@implementation GetPartyVisitHistoryViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[GetPartyVisitListService alloc] init];
        _service.delegate = self;
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        _visitsFilter = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"历史拜访";
    
    [self registerCell];
    
    [_resultLabel setText:@""];
    [_resultLabel setStartTime:@"2017-1-1"];
    [_resultLabel setEndTime:@"2020-1-1"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _page = 1;
    [_service GetPartyVisitHistory:_app.business.BUSINESS_IDX andStrPartyCode:_pvItemM.pARTYNO andStartTime:_resultLabel.startTime andEndTime:_resultLabel.endTime];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - 事件

- (IBAction)timeOnclick {
    
    _blurredView = [[LMBlurredView alloc] init];
    _blurredView.delegate = self;
    [_blurredView blurry:5.1];
    
    [_dataView setAlpha:0];
    [self.view.window addSubview:self.dataView];
    [UIView animateWithDuration:0.5 animations:^{
        
        [_dataView setAlpha:1];
    } completion:^(BOOL finished) {
    }];
}


#pragma mark - 功能函数

// 注册Cell
- (void)registerCell {
    
    [_tableView registerNib:[UINib nibWithNibName:kCellName bundle:nil] forCellReuseIdentifier:kCellName];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (LLDateFilterView *)dataView {
    if (!_dataView) {
        CGRect frame = CGRectMake(0, 200, self.view.width, 300);
        _dataView = [[LLDateFilterView alloc]initWithFrame:frame buttonTitles:@[@"重置",@"完成"] quickSelected:YES startDate:nil endDate:[NSDate date]];
        __weak typeof(self) weakSelf = self;
        _dataView.finishBlock = ^(LLDateFilterView *bView, NSString *bLeftDate, NSString *bRightDate, NSString * title) {
            if (bLeftDate==nil) {
                [weakSelf.dataView cleanDate];
            }else{
                [weakSelf.dataView removeFromSuperview];
                weakSelf.resultLabel.text = [NSString stringWithFormat:@"%@ 到 %@",bLeftDate,bRightDate];
                weakSelf.resultLabel.startTime = bLeftDate;
                weakSelf.resultLabel.endTime = bRightDate;
                
                [weakSelf.service GetPartyVisitHistory:weakSelf.app.business.BUSINESS_IDX andStrPartyCode:weakSelf.pvItemM.pARTYNO andStartTime:weakSelf.resultLabel.startTime andEndTime:weakSelf.resultLabel.endTime];
                
                [weakSelf.blurredView clear];
            }
        };
    }
    return _dataView;
}


- (void)visit:(NSUInteger)row {
    
    GetPartyVisitItemModel *m = _visitsFilter[row];
    
    PartyModel *partyM = [[PartyModel alloc] init];
    partyM.PARTY_CODE = m.pARTYNO;
    partyM.PARTY_NAME = m.pARTYNAME;
    partyM.PARTY_LEVEL = m.pARTYLEVEL;
    partyM.PARTY_STATES = m.pARTYSTATES;
    partyM.CHANNEL = m.cHANNEL;
    partyM.LINE = m.lINE;
    partyM.WEEKLY_VISIT_FREQUENCY = m.wEEKLYVISITFREQUENCY;
    
    AddressModel *addressM = [[AddressModel alloc] init];
    addressM.CONTACT_PERSON = m.cONTACTS;
    addressM.CONTACT_TEL = m.cONTACTSTEL;
    addressM.ADDRESS_INFO = m.pARTYADDRESS;
    
    GetPartyVisitItemModel *_pvItemM = _visitsFilter[row];
    
    if([_pvItemM.vISITSTATES isEqualToString:@""]||[_pvItemM.vISITSTATES isEqualToString:@""]) {
        
        AddPartyVisitViewController *vc = [[AddPartyVisitViewController alloc] init];
        vc.partyM = partyM;
        vc.addressM = addressM;
        vc.pvItemM = m;
        [self.navigationController pushViewController:vc animated:YES];
    } else if([_pvItemM.vISITSTATES isEqualToString:@"新建"] || [_pvItemM.vISITSTATES isEqualToString:@"确认客户信息"]){
        GetVisitEnterShopViewController *vc = [[GetVisitEnterShopViewController alloc] init];
        vc.pvItemM = _pvItemM;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if([_pvItemM.vISITSTATES isEqualToString:@"进店"]){
        
        GetVisitCheckInventoryViewController *vc = [[GetVisitCheckInventoryViewController alloc] init];
        vc.pvItemM = _pvItemM;
        [self.navigationController pushViewController:vc animated:YES];
    } else if([_pvItemM.vISITSTATES isEqualToString:@"检查库存"]){
        
        GetVisitRecommendedOrderViewController *vc = [[GetVisitRecommendedOrderViewController alloc] init];
        vc.pvItemM = _pvItemM;
        [self.navigationController pushViewController:vc animated:YES];
    } else if([_pvItemM.vISITSTATES isEqualToString:@"建议订单"]){
        
        GetVisitVividDisplayViewController *vc = [[GetVisitVividDisplayViewController alloc] init];
        vc.pvItemM = _pvItemM;
        [self.navigationController pushViewController:vc animated:YES];
    } else if([_pvItemM.vISITSTATES isEqualToString:@"生动化陈列"]){
        
        KBShowStepViewController *vc = [[KBShowStepViewController alloc] init];
        vc.pvItemM = _pvItemM;
        vc.isShowConfirmBtn = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if([_pvItemM.vISITSTATES isEqualToString:@"离店"]){
        
    }
    
    NSLog(@"%lu", (unsigned long)row);
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _visitsFilter.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 处理界面
    static NSString *cellId = kCellName;
    GetPartyVisitHistoryTableViewCell *cell = (GetPartyVisitHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    GetPartyVisitItemModel *m = _visitsFilter[indexPath.row];
    
    cell.getPartyVisitItemM = m;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KBShowStepViewController *vc = [[KBShowStepViewController alloc] init];
    GetPartyVisitItemModel *m = _visitsFilter[indexPath.row];
    vc.pvItemM = m;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - GetPartyVisitListServiceDelegate

- (void)successOfGetPartyVisitHistory:(GetPartyVisitListModel *)getPartyVisitListM {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView.mj_footer endRefreshing];
    _tableView.mj_footer.hidden = NO;
    
    // 页数处理
    if(_page == 1) {
        
        _visitsFilter = [getPartyVisitListM.getPartyVisitItemModel mutableCopy];
        if(_visitsFilter.count < kPageCount) {
            
            [_tableView.mj_footer setCount_NoMoreData:_visitsFilter.count];
        }
    } else {
        
        for(int i = 0; i < getPartyVisitListM.getPartyVisitItemModel.count; i++) {
            
            GetPartyVisitListModel *item = getPartyVisitListM.getPartyVisitItemModel[i];
            [_visitsFilter addObject:item];
        }
    }
    
    // 处理Cell高度
    [_tableView reloadData];
    [_tableView removeNoOrderPrompt];
}


- (void)successOfGetPartyVisitHistory_NoData {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView.mj_header endRefreshing];
    
    if(_page == 1) { // 没有数据
        
        [_visitsFilter removeAllObjects];
        _tableView.mj_footer.hidden = YES;
        [_tableView noData:kPrompt andImageName:LM_NoResult_noOrder];
    } else {  // 已加载完毕
        
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        [_tableView removeNoOrderPrompt];
        [_tableView.mj_footer setCount_NoMoreData:_visitsFilter.count];
    }
    [_tableView reloadData];
}

- (void)failureOfGetPartyVisitHistory:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [_tableView.mj_footer endRefreshing];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取信息失败，服务器无返回错误信息"];
    if(_page == 1) {
        
        [_tableView noData:kPrompt andImageName:LM_NoResult_noOrder];
    }
    [_tableView reloadData];
}


#pragma mark - LMBlurredViewDelegate

- (void)LMBlurredViewClear {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        [_dataView setAlpha:0];
    } completion:^(BOOL finished) {
        
        [_dataView removeFromSuperview];
    }];
}


#pragma mark - GetPartyVisitHistoryTableViewCellDelegate

- (void)continueOnclick:(NSUInteger)row {
    
    [self visit:row];
}

@end
