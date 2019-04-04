//
//  PrintVC.m
//  Order
//
//  Created by wenwang wang on 2019/4/3.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "PrintVC.h"
#import "Tools.h"

#import "XYBLEManager.h"
#import "SelectionDeviceVC.h"
#import "PosCommand.h"
#import "AppDelegate.h"

@interface PrintVC ()<UIAlertViewDelegate>

/** BLE */
@property (strong, nonatomic) XYBLEManager *manager;

// 销售单总金额
@property (assign, nonatomic) float outPutTotalPrice;

// 采购单总金额
@property (assign, nonatomic) float inPutTotalPrice;

// 是否打开蓝牙
@property (strong, nonatomic) Tools *t;

// 连接/断开按钮
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation PrintVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"蓝牙打印";
    
    _outPutTotalPrice = 0.0;
    _inPutTotalPrice = 0.0;
    
    _t = [[Tools alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectBle:) name:ConnectBleSuccessNote object:nil];
    [self.manager addObserver:self
                   forKeyPath:@"writePeripheral.state"
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    self.manager.delegate = self;
}


- (void)dealloc {
    
    [self.manager XYdisconnectRootPeripheral];
    [self.manager removeObserver:self forKeyPath:@"writePeripheral.state" context:nil];
}

#pragma mark - 通知

- (void)connectBle:(NSNotification *)text{
    
    [self.statusBtn setTitle:@"断开连接" forState:UIControlStateNormal];
    [self.statusBtn setBackgroundColor:[UIColor redColor]];
    SharedAppDelegate.isConnectedBLE = YES ;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (self.manager && object == self.manager && [keyPath isEqualToString:@"writePeripheral.state"]) {
        // 更行蓝牙的连接状态
        switch (self.manager.writePeripheral.state) {
            case CBPeripheralStateDisconnected:
            {
                [self.statusBtn setTitle:@"蓝牙连接" forState:UIControlStateNormal];
                [self.statusBtn setBackgroundColor:RGB(61, 147, 73)];
                SharedAppDelegate.isConnectedBLE = NO;
                break;
            }
                
            case CBPeripheralStateConnecting:
            {
                [self.statusBtn setTitle:@"设备正在连接" forState:UIControlStateNormal];
                break;
            }
            case CBPeripheralStateConnected:
            {
                [self.statusBtn setTitle:@"已连接" forState:UIControlStateNormal];
                [self.statusBtn setBackgroundColor:[UIColor redColor]];
                SharedAppDelegate.isConnectedBLE = YES;
                break;
            }
            case CBPeripheralStateDisconnecting:
            {
                [self.statusBtn setTitle:@"蓝牙连接" forState:UIControlStateNormal];
                [self.statusBtn setBackgroundColor:RGB(61, 147, 73)];
                SharedAppDelegate.isConnectedBLE = NO;
                break;
            }
            default:
                break;
        };
    }
}


- (IBAction)connectOnclick {
    
    if(SharedAppDelegate.isConnectedBLE) {
        
        [self.manager XYdisconnectRootPeripheral];
    }else {
        
        SelectionDeviceVC *vc = [[SelectionDeviceVC alloc] init];;
        vc.callBack = ^(id x){
            SharedAppDelegate.isConnectedBLE = YES;
            SharedAppDelegate.isConnectedWIFI = NO;
            NSString *message = @"蓝牙连接成功";
            [Tools showAlert:self.view andTitle:message];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//打印文字
- (IBAction)printOnclick {
    
    BOOL b = [_t blueToothOpen];
    
    if(!b) {
        
        [Tools showAlert:self.view andTitle:@"请打开蓝牙"];
        return;
    }
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSMutableData* dataM=[NSMutableData dataWithData:[XYCommand initializePrinter]];
    
    // 头部
    // 抬头 居中
    [dataM appendData:[XYCommand selectAlignment:1]];
    [dataM appendData: [@"深圳市凯东源贸易有限公司" dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    [dataM appendData:[XYCommand selectAlignment:0]];
    [dataM appendData: [@"---------------------------------------------" dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    
    // 客户名称
    NSString *patyName = @"";
    if(_getOupputDetailM) {
        
        patyName = _getOupputDetailM.getOupputInfoModel.pARTYNAME;
    }else if(_order){
        
        patyName = _order.ORD_TO_NAME;
    }
    
    // 客户名称 居左
    NSString *partyName = [NSString stringWithFormat:@"客户名称：%@", patyName];
    [dataM appendData: [partyName dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    [dataM appendData: [@"---------------------------------------------" dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    // 商品格式说明 居左
    [dataM appendData: [@"商品/数量/单价" dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    [dataM appendData: [@"---------------------------------------------" dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    [dataM appendData:[XYCommand selectAlignment:0]];
    
    // 销售出库单
    if(_getOupputDetailM) {
        
        // 订单
        if(_getOupputDetailM) {
            
            for (int i = 0; i < _getOupputDetailM.getOupputItemModel.count; i++) {
                
                GetOupputItemModel *getOupputItemM = _getOupputDetailM.getOupputItemModel[i];
                
                NSString *name = [NSString stringWithFormat:@"%d.%@", i + 1, getOupputItemM.pRODUCTNAME];
                
                // 数量占位t符
                NSString *qtyLoc = @"abcdefgheijklnmopqrstuv";
                int nameLenght = [Tools textLength:name];
                int pad = [Tools textLength:qtyLoc] - nameLenght;
                if(pad > 0){
                    for (int i = 0; i < pad; i++) {
                        name = [name stringByAppendingFormat:@" "];
                    }
                }
                
                // 名称
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:00 andNH:00]];
                [dataM appendData: [name dataUsingEncoding: gbkEncoding]];
                
                // 数量
                NSString *qty = [NSString stringWithFormat:@"   x%@[%@]", [Tools  OneDecimal:getOupputItemM.oUTPUTQTY], getOupputItemM.oUTPUTUOM];
                [dataM appendData: [qty dataUsingEncoding: gbkEncoding]];
                
                // 金额
                NSString *price = [NSString stringWithFormat:@"￥%.2f", [getOupputItemM.oRGPRICE floatValue] - [getOupputItemM.mJPRICE floatValue]];
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:200 andNH:01]];
                [dataM appendData: [price dataUsingEncoding: gbkEncoding]];
                [dataM appendData:[XYCommand printAndFeedLine]];
                
                // 总金额
                _outPutTotalPrice += ([getOupputItemM.oRGPRICE floatValue] - [getOupputItemM.mJPRICE floatValue]) * [getOupputItemM.oUTPUTQTY floatValue];
            }
        }
    }else if(_order){
        
        // 订单
        if(_arrGoods.count > 0) {
            
            for (int i = 0; i < _arrGoods.count; i++) {
                
                OrderDetailModel *m = _arrGoods[i];
                
                NSString *name = [NSString stringWithFormat:@"%d.%@", i + 1, m.PRODUCT_NAME];
                
                // 数量占位t符
                NSString *qtyLoc = @"abcdefgheijklnmopqrstuv";
                int nameLenght = [Tools textLength:name];
                int pad = [Tools textLength:qtyLoc] - nameLenght;
                if(pad > 0){
                    for (int i = 0; i < pad; i++) {
                        name = [name stringByAppendingFormat:@" "];
                    }
                }
                
                // 名称
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:00 andNH:00]];
                [dataM appendData: [name dataUsingEncoding: gbkEncoding]];
                
                // 数量
                NSString *qty = [NSString stringWithFormat:@"   x%.1f", m.ISSUE_QTY];
                [dataM appendData: [qty dataUsingEncoding: gbkEncoding]];
                
                // 金额
                NSString *price = [NSString stringWithFormat:@"￥%.2f", m.ACT_PRICE];
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:200 andNH:01]];
                [dataM appendData: [price dataUsingEncoding: gbkEncoding]];
                [dataM appendData:[XYCommand printAndFeedLine]];
                
                // 总金额
                _inPutTotalPrice += m.ACT_PRICE * m.ORDER_QTY;
            }
        }
    }else {
        
        [Tools showAlert:self.view andTitle:@"无订单"];
    }
    
    // 总数量
    float totalQTY = 0.0;
    // 总金额
    float totalPrice = 0.0;
    // 订单号
    NSString *orderNO = @"";
    
    if(_getOupputDetailM) {
        
        totalQTY = [_getOupputDetailM.getOupputInfoModel.oUTPUTQTY floatValue];
        totalPrice = _outPutTotalPrice;
        orderNO = _getOupputDetailM.getOupputInfoModel.oUTPUTNO;
    }else if(_order){
        
        totalQTY = _order.ORD_QTY;
        totalPrice = _order.ACT_PRICE;
        orderNO = _order.ORD_NO;
    }
    
    // 尾部
    // 总数量、总金额
    [dataM appendData:[XYCommand selectAlignment:0]];
    [dataM appendData: [@"---------------------------------------------" dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    NSString *total = [NSString stringWithFormat:@"总数量：%.1f     总金额：%.2f", totalQTY, totalPrice];
    [dataM appendData: [total dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    
    // 打印时间、开单人、帐号
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:udUserName];
    NSString *time = [NSString stringWithFormat:@"%@  [%@  %@]", [Tools getCurrentDate], SharedAppDelegate.user.USER_NAME, userName];
    [dataM appendData: [time dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    
    // 订单号
    NSString *ordNo = [NSString stringWithFormat:@"订单号：%@", orderNO];
    [dataM appendData: [ordNo dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    
    if (SharedAppDelegate.isConnectedBLE) {
        
        [self.manager XYWriteCommandWithData:dataM];
    }else{
        
        [Tools showAlert:self.view andTitle:@"请连接蓝牙"];
    }
}

#pragma mark - GET方法

- (XYBLEManager *)manager {
    
    if (!_manager) {
        
        _manager = [XYBLEManager sharedInstance];
        _manager.delegate = self;
    }
    return _manager;
}

@end
