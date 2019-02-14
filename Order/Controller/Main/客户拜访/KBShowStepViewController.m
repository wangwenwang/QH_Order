//
//  KBShowStepViewController.m
//  Order
//
//  Created by wenwang wang on 2018/11/21.
//  Copyright © 2018年 凯东源. All rights reserved.
//

#import "KBShowStepViewController.h"
#import "GetVisitEnterShopService.h"
#import "Tools.h"
#import <MBProgressHUD.h>
#import "AppDelegate.h"
#import "PhotoBroswerVC.h"
#include <Masonry.h>
#import "ACMediaFrame.h"
#import "UIView+ACMediaExt.h"
#import "GetOupputListTableViewCell.h"
#import "GetOupputListModel.h"
#import "GetOupputInfoViewController.h"
#import "UITableView+NoDataPrompt.h"
#import "Store_GetOupputListService.h"
#import "GetVisitVividDisplayViewController.h"
#import "GetPartyVisitListViewController.h"
#import "GetPartyVisitListService.h"
#import "ShowCheckInventoryTableViewCell.h"

// 查看经销商入库单
#import "CheckAgentOrderTableViewCell.h"
#import "OrderDetailService.h"
#import "OrderDetailViewController.h"

@interface KBShowStepViewController ()<GetVisitEnterShopServiceDelegate, Store_GetOupputListServiceDelegate, GetPartyVisitListServiceDelegate, OrderDetailServiceDelegate>

// 全局变量
@property (strong, nonatomic) AppDelegate *app;

// 网络层
@property (strong, nonatomic) GetVisitEnterShopService *service;

// 网络层
@property (strong, nonatomic) Store_GetOupputListService *service_visitOrder;

@property (weak, nonatomic) IBOutlet UIView *stepView1;

// 第一步，进店位置
@property (weak, nonatomic) IBOutlet UILabel *ACTUAL_VISITING_ADDRESS;

// 进店图片
@property (weak, nonatomic) IBOutlet UIView *VisitEnterShop_imageContainerView;

// 出库列表
@property (strong, nonatomic) GetOupputListModel *getOupputListM;

// 确认客户信息
@property (weak, nonatomic) IBOutlet UILabel *PARTY_NO;
@property (weak, nonatomic) IBOutlet UILabel *PARTY_NAME;
@property (weak, nonatomic) IBOutlet UILabel *CONTACTS;
@property (weak, nonatomic) IBOutlet UILabel *CONTACTS_TEL;

// 第三步，检查库存
@property (weak, nonatomic) IBOutlet UILabel *CHECK_INVENTORY;
@property (weak, nonatomic) IBOutlet UITableView *tableView_checkInventory;
@property (weak, nonatomic) NSArray *checkInventorys;

// 第四步，建议订单
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 备注
@property (weak, nonatomic) IBOutlet UILabel *RECOMMENDED_ORDER;
//


// 第五步，生动化陈列
@property (weak, nonatomic) IBOutlet UILabel *VIVID_DISPLAY_TEXT;

// 装图片的容器
@property (weak, nonatomic) IBOutlet UIView *VIVID_DISPLAY_TEXT_imageContainerView;

// 第六步，离店
@property (weak, nonatomic) IBOutlet UILabel *LeaveTheStore;

// 统计高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *step1ViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *step2ViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *step3ViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *step4ViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *step5ViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *step6ViewHeight;


// 订单列表数据
@property (strong, nonatomic) CheckOrderListModel *CheckOrderListM;



@end

#define kCellHeight_ShowOrder 103

#define kCellHeight_ShowCheckInventory 33

#define kCellNameGetOupputList @"GetOupputListTableViewCell"

#define kCellNameCheckAgentOrder @"CheckAgentOrderTableViewCell"

#define kCellNameCheckInventory @"ShowCheckInventoryTableViewCell"

@implementation KBShowStepViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[GetVisitEnterShopService alloc] init];
        _service.delegate = self;
        
        _service_visitOrder = [[Store_GetOupputListService alloc] init];
        _service_visitOrder.delegate = self;
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"查看拜访";
    
    [self registerCell];
    
    [self dealData];
    
    [self initUI];
    
    [_service GetPictureByVisitIdx:_pvItemM.vISITIDX andStrStep:@"Visit"];
    [_service GetPictureByVisitIdx:_pvItemM.vISITIDX andStrStep:@"VisitVividDisplay"];
    
    if([_pvItemM.gRADE isEqualToString:@"0"]) {
        
        [Tools showAlert:self.view andTitle:@"当前被拜访的客户为供货商，无出库单"];
    }else if([_pvItemM.gRADE isEqualToString:@"1"]) {
        
        [_service_visitOrder GetVisitAppOrde_AGENT:_pvItemM.vISITIDX andStrType:@"AppOrder"];
    }else if([_pvItemM.gRADE isEqualToString:@"2"]) {
        
        [_service_visitOrder GetVisitAppOrder:_pvItemM.vISITIDX andStrType:@"OutPut"];
    }else {
        
        [Tools showAlert:self.view andTitle:@"未知客户类型，字段GRADE"];
    }
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    _scrollContainerViewHeight.constant = _step1ViewHeight.constant + _step2ViewHeight.constant + _step3ViewHeight.constant + _step4ViewHeight.constant + _step5ViewHeight.constant + _step6ViewHeight.constant;
    
    
    if(_isShowConfirmBtn) {
        
        _scrollContainerViewHeight.constant = _step1ViewHeight.constant + _step2ViewHeight.constant + _step3ViewHeight.constant + _step4ViewHeight.constant + _step5ViewHeight.constant + _step6ViewHeight.constant + 80;
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - 功能函数

// 注册Cell
- (void)registerCell {
    
    [_tableView registerNib:[UINib nibWithNibName:kCellNameGetOupputList bundle:nil] forCellReuseIdentifier:kCellNameGetOupputList];
    [_tableView registerNib:[UINib nibWithNibName:kCellNameCheckAgentOrder bundle:nil] forCellReuseIdentifier:kCellNameCheckAgentOrder];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView_checkInventory registerNib:[UINib nibWithNibName:kCellNameCheckInventory bundle:nil] forCellReuseIdentifier:kCellNameCheckInventory];
    _tableView_checkInventory.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)dealData {
    
    _checkInventorys = [_pvItemM.cHECKINVENTORY componentsSeparatedByString:@"^；"];
}

- (void)setCheckInventory {
    if(_checkInventorys.count > 1) {
        _step3ViewHeight.constant = 30 + kCellHeight_ShowCheckInventory * (_checkInventorys.count - 1) + 30;
        [self updateViewConstraints];
    }
    [_tableView_checkInventory reloadData];
    _CHECK_INVENTORY.text = [_checkInventorys lastObject];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView.tag == 1001) {
        
        //『供货商』对『经销商』的入库单
        if(_CheckOrderListM) {
            
            return _CheckOrderListM.checkOrderItemModel.count;
        }
        //『经销商』对『门店』的出库单
        else {
            
            return _getOupputListM.getOupputModel.count;
        }
    }
    else if(tableView.tag == 1002) {
        
        return _checkInventorys.count - 1;
    }else {
        
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        //『供货商』对『经销商』的入库单
        if(_CheckOrderListM) {
            
            return kCellHeight_ShowOrder;
        }
        //『经销商』对『门店』的出库单
        else {
            
            GetOupputModel *getOupputM = _getOupputListM.getOupputModel[indexPath.row];
            return getOupputM.cellHeight;
        }
    }else if(tableView.tag == 1002) {
        
        return kCellHeight_ShowCheckInventory;
    }else {
        
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        //『供货商』对『经销商』的入库单
        if(_CheckOrderListM) {
            
            static NSString *cellID = kCellNameCheckAgentOrder;
            CheckAgentOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            
            CheckOrderItemModel *CheckOrderItemM = _CheckOrderListM.checkOrderItemModel[indexPath.row];
            
            cell.CheckOrderItemM = CheckOrderItemM;
            
            return cell;
        }
        //『经销商』对『门店』的出库单
        else {
            
            static NSString *cellId = kCellNameGetOupputList;
            GetOupputListTableViewCell *cell = (GetOupputListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
            
            GetOupputModel *getOupputM = _getOupputListM.getOupputModel[indexPath.row];
            
            cell.getOupputM = getOupputM;
            
            return cell;
        }
        
    }else if(tableView.tag == 1002) {
        
        static NSString *cellId = kCellNameCheckInventory;
        ShowCheckInventoryTableViewCell *cell = (ShowCheckInventoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        cell.productNameLabel.text = _checkInventorys[indexPath.row];
        return cell;
    }else {
        
        return [[UITableViewCell alloc] init];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView.tag == 1001) {
        
        //『供货商』对『经销商』的入库单
        if(_CheckOrderListM) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            CheckOrderItemModel *m = _CheckOrderListM.checkOrderItemModel[indexPath.row];
            OrderDetailService *service = [[OrderDetailService alloc] init];
            service.delegate = self;
            [service getOrderDetailsData:m.iDX];
        }
        //『经销商』对『门店』的出库单
        else {
            
            [_tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            GetOupputModel *m = _getOupputListM.getOupputModel[indexPath.row];
            
            GetOupputInfoViewController *vc = [[GetOupputInfoViewController alloc] init];
            vc.oupputM = m;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


#pragma mark - 事件

- (void)initUI {
    
    _PARTY_NO.text = _pvItemM.pARTYNO;
    _PARTY_NAME.text = _pvItemM.pARTYNAME;
    _CONTACTS.text = _pvItemM.cONTACTS;
    _CONTACTS_TEL.text = _pvItemM.cONTACTSTEL;
    
    _ACTUAL_VISITING_ADDRESS.text = _pvItemM.aCTUALVISITINGADDRESS;
    [self setCheckInventory];
    _RECOMMENDED_ORDER.text = _pvItemM.rECOMMENDEDORDER;
    _VIVID_DISPLAY_TEXT.text = _pvItemM.vIVIDDISPLAYTEXT;
    _LeaveTheStore.text = _pvItemM.vISITSTATES;
    
    
    if(_isShowConfirmBtn) {
        
        GetPartyVisitListService *s = [[GetPartyVisitListService alloc] init];
        s.delegate = self;
        
        //改 填充strFartherPartyID
        [s GetPartyVisitList:1 andstrPageCount:99 andStrSearch:@"" andStrLine:@"全部" andStatus:@"全部" andStrUserID:_app.user.IDX andStrFartherPartyID:_pvItemM.fARTHERADDRESSID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.title = @"离店";
            
            UIButton *btn = [[UIButton alloc] init];
            [self.view addSubview:btn];
            [btn setBackgroundColor:[UIColor redColor]];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [btn setTitle:@"确认离店" forState:UIControlStateNormal];
            btn.layer.cornerRadius = 20;
            btn.layer.shadowOffset =  CGSizeMake(0, 3);
            btn.layer.shadowOpacity = 0.5;
            btn.layer.shadowColor =  [UIColor redColor].CGColor;
            [btn addTarget:self action:@selector(LeaveShopOnclick) forControlEvents:UIControlEventTouchUpInside];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(150);
                make.height.mas_equalTo(40);
                make.top.mas_equalTo(CGRectGetHeight(self.view.frame) - 80);
                //                make.bottom.mas_equalTo(kStatusHeight + kNavHeight + 50);
                make.centerX.offset(0);
            }];
        });
    }
}


- (void)LeaveShopOnclick {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service GetVisitLeaveShop:_pvItemM.vISITIDX];
}


#pragma mark - GetVisitEnterShopServiceDelegate

- (void)successOfGetPictureByVisitIdx:(NSArray *)arrayUrl andType:(NSString *)type {
    
    NSMutableArray *urlArrM = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in arrayUrl) {
        
        NSString *url = [NSString stringWithFormat:@"%@/%@", API_SERVER_AUTOGRAPH_AND_PICTURE_FILE, dict[@"PRODUCT_URL"]];
        [urlArrM addObject:url];
    }
    
    if([type isEqualToString:@"Visit"]) {
        
        ACSelectMediaView *mediaView = [[ACSelectMediaView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 1)];
        mediaView.showDelete = NO;
        mediaView.showAddButton = NO;
        mediaView.preShowMedias = [urlArrM copy];
        [_VisitEnterShop_imageContainerView addSubview:mediaView];
    }else if([type isEqualToString:@"VisitVividDisplay"]) {
        
        ACSelectMediaView *mediaView = [[ACSelectMediaView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 1)];
        mediaView.showDelete = NO;
        mediaView.showAddButton = NO;
        mediaView.preShowMedias = [urlArrM copy];
        [_VIVID_DISPLAY_TEXT_imageContainerView addSubview:mediaView];
        
        _step5ViewHeight.constant = 30 + ((urlArrM.count - 1) / 4 + 1) * 100 + 30;
        [self updateViewConstraints];
    }
    
}

- (void)failureOfGetPictureByVisitIdx:(NSString *)msg andType:(nullable NSString *)type {
    
    [MBProgressHUD hideHUDForView:self.stepView1 animated:YES];
    
    // 加载进店图片没数据，但还没到此步骤不提示错误
    if([type isEqualToString:@"Visit"] && (_pvItemM.vISITSTATES)) {
        
    }
    // 加载生陈列动画图片没数据，但还没到此步骤不提示错误
    else if([type isEqualToString:@"VisitVividDisplay"]) {
        
    }else {
        
        [Tools showAlert:self.view andTitle:msg];
    }
}

- (void)successOfGetVisitLeaveShop:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
    
    NSArray *array = self.navigationController.viewControllers;
    
    for (UIViewController *vc in array) {
        
        if([vc isKindOfClass:[GetPartyVisitListViewController class]]) {
            
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)failureOfGetVisitLeaveShop:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
}

#pragma mark - Store_GetOupputListServiceDelegate

- (void)successOfGetOupputList:(GetOupputListModel *)getOupputListM {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    _getOupputListM = getOupputListM;
    
    CGFloat tableViewHeight = 0;
    for (GetOupputModel *m in _getOupputListM.getOupputModel) {
        
        // 单行高度
        CGFloat oneLine = [Tools getHeightOfString:@"fds" fontSize:13 andWidth:ScreenWidth];
        
        CGFloat PARTY_NAME_height = [Tools getHeightOfString:m.pARTYNAME fontSize:13 andWidth:(ScreenWidth - 8 - 61 - 3)];
        
        CGFloat oneCellHeight = 0;
        if(PARTY_NAME_height > oneLine) {
            
            oneCellHeight = kCellHeight_ShowOrder + PARTY_NAME_height - oneLine;
        } else {
            
            oneCellHeight = kCellHeight_ShowOrder;
        }
        m.cellHeight = oneCellHeight;
        
        tableViewHeight += oneCellHeight;
    }
    _step4ViewHeight.constant = 30 + tableViewHeight + 30;
    [self updateViewConstraints];
    
    [_tableView removeNoOrderPrompt];
    [_tableView reloadData];
}


- (void)successOfGetOupputList_NoData {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView noData:@"没有销售订单" andImageName:LM_NoResult_noOrder];
}


- (void)failureOfGetOupputList:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取出库列表失败"];
}


- (void)successOfGetOupputList_CheckOrder:(CheckOrderListModel *)CheckOrderListM {
    
    _CheckOrderListM = CheckOrderListM;
    
    _step4ViewHeight.constant = 30 + kCellHeight_ShowOrder + 30;
    [self updateViewConstraints];
    
    [_tableView removeNoOrderPrompt];
    [_tableView reloadData];
}


#pragma mark - GetPartyVisitListServiceDelegate

- (void)successOfGetPartyVisitList:(GetPartyVisitListModel *)getPartyVisitListM andsStrSearch:(nullable NSString *)strSearch{
    
    for (GetPartyVisitItemModel *m in getPartyVisitListM.getPartyVisitItemModel) {
        if([m.vISITIDX isEqualToString:_pvItemM.vISITIDX]) {
            
            _pvItemM.aCTUALVISITINGADDRESS = m.aCTUALVISITINGADDRESS;
            _pvItemM.cHECKINVENTORY = m.cHECKINVENTORY;
            _pvItemM.rECOMMENDEDORDER = m.rECOMMENDEDORDER;
            _pvItemM.vIVIDDISPLAYTEXT = m.vIVIDDISPLAYTEXT;
            _pvItemM.vISITSTATES = m.vISITSTATES;
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _ACTUAL_VISITING_ADDRESS.text = _pvItemM.aCTUALVISITINGADDRESS;
        [self setCheckInventory];
        _RECOMMENDED_ORDER.text = _pvItemM.rECOMMENDEDORDER;
        _VIVID_DISPLAY_TEXT.text = _pvItemM.vIVIDDISPLAYTEXT;
        _LeaveTheStore.text = _pvItemM.vISITSTATES;
    });
}

#pragma mark - OrderDetailServiceDelegate

- (void)successOfOrderDetail:(OrderModel *)order {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    OrderDetailViewController *vc = [[OrderDetailViewController alloc] init];
    vc.order = order;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)failureOfOrderDetail:(NSString *)msg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取失败"];
}

@end
