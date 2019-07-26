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
#import "LM_alert.h"

@interface PrintVC ()<UIAlertViewDelegate, XYBLEManagerDelegate>

/** BLE */
@property (strong, nonatomic) XYBLEManager *manager;

// 是否打开蓝牙
@property (strong, nonatomic) Tools *t;

// 连接/断开按钮
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation PrintVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title =  @"蓝牙打印";
    
    _t = [[Tools alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectBle:) name:ConnectBleSuccessNote object:nil];
    [self.manager addObserver:self
                   forKeyPath:@"writePeripheral.state"
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:nil];
    [self.manager XYstartScan];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        usleep(1000000);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL b = [_t blueToothOpen];
            
            if(!b) {
                [LM_alert showLMAlertViewWithTitle:@"请打开蓝牙" message:@"" cancleButtonTitle:@"确定" okButtonTitle:nil otherButtonTitleArray:nil];
            }
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    self.manager.delegate = self;
}


- (void)dealloc {
    
    [self.manager XYdisconnectRootPeripheral];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ConnectBleSuccessNote object:nil];
    [self.manager removeObserver:self forKeyPath:@"writePeripheral.state" context:nil];
    //    [_t stopBleScan];
    [self.manager XYstopScan];
    self.manager.delegate = nil;
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
                [self.statusBtn setTitle:@"断开连接" forState:UIControlStateNormal];
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
    
    [self printText:@"客户联"];
    [self printText:@"虚线"];
    [self printText:@"回单联"];
}

- (void)printText:(NSString *)CUSTOM_OR_RECEIPT {
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSMutableData* dataM=[NSMutableData dataWithData:[XYCommand initializePrinter]];
    
    if ([CUSTOM_OR_RECEIPT isEqualToString:@"虚线"]) {
        
        [dataM appendData:[XYCommand printAndFeedLine]];
        [dataM appendData: [@"- - - - - - - - - - - - - - - - - - - - - - - -" dataUsingEncoding: gbkEncoding]];
        [dataM appendData:[XYCommand printAndFeedLine]];
        [dataM appendData:[XYCommand printAndFeedLine]];
        if (SharedAppDelegate.isConnectedBLE) {
            
            [self.manager XYWriteCommandWithData:dataM];
        }else{
            
            [Tools showAlert:self.view andTitle:@"请连接蓝牙"];
        }
        return;
    }
    
    // 客户联|回单联
    [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:200 andNH:01]];
    if ([CUSTOM_OR_RECEIPT isEqualToString:@"客户联"]) {
        [dataM appendData: [@"【客户联】" dataUsingEncoding: gbkEncoding]];
    }else if ([CUSTOM_OR_RECEIPT isEqualToString:@"回单联"]) {
        [dataM appendData: [@"【回单联】" dataUsingEncoding: gbkEncoding]];
    }
    [dataM appendData:[XYCommand printAndFeedLine]];
    
    // 头部
    // 抬头 居中
    [dataM appendData:[XYCommand selectAlignment:1]];
    if(_getOupputDetailM) {
        [dataM appendData: [_getOupputDetailM.getOupputInfoModel.aDDRESSNAME dataUsingEncoding: gbkEncoding]];
    }else if(_order){
        [dataM appendData: [[NSString stringWithFormat:@"%@", _order.ORD_FROM_NAME] dataUsingEncoding: gbkEncoding]];
    }
    [dataM appendData:[XYCommand printAndFeedLine]];
    [dataM appendData:[XYCommand selectAlignment:0]];
    [dataM appendData: [@"---------------------------------------------" dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    
    // 客户代码
    NSString *partyCode = @"";
    // 客户名称
    NSString *partyName = @"";
    // 客户地址
    NSString *partyAddress = @"";
    // 客户电话
    NSString *partyTel = @"";
    if(_getOupputDetailM) {
        
        partyCode = _getOupputDetailM.getOupputInfoModel.pARTYCODE;
        partyName = _getOupputDetailM.getOupputInfoModel.pARTYNAME;
        partyAddress = _getOupputDetailM.getOupputInfoModel.pARTYINFO;
        partyTel = _getOupputDetailM.getOupputInfoModel.pARTYTEL;
    }else if(_order){
        
        partyName = _order.ORD_TO_NAME;
        partyAddress = _order.ORD_TO_ADDRESS;
        partyTel = _order.ORD_TO_CTEL;
        partyCode = _order.ORD_TO_CODE;
    }
    
    // 客户代码/电话/ 居左
    partyCode = [NSString stringWithFormat:@"客户代码：%@   [%@]", partyCode, partyTel];
    [dataM appendData: [partyCode dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    // 客户名称 居左
    partyName = [NSString stringWithFormat:@"客户名称：%@", partyName];
    [dataM appendData: [partyName dataUsingEncoding: gbkEncoding]];
    [dataM appendData:[XYCommand printAndFeedLine]];
    // 客户地址 居左
    partyName = [NSString stringWithFormat:@"客户地址：%@", partyAddress];
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
                // 产品名称太长，分两行
                NSString *namePadPreix = name;
                NSString *nameSuffix = @"";
                
                // 数量占位t符
                NSString *qtyLoc = @"abcdefgheijklnmopqrstuv";
                int nameLenght = [Tools textLength:namePadPreix];
                int pad = [Tools textLength:qtyLoc] - nameLenght;
                if(pad > 0){
                    for (int i = 0; i < pad; i++) {
                        namePadPreix = [namePadPreix stringByAppendingFormat:@" "];
                    }
                }
                
                // 产品名称超过设置长度，自动换行
                if(pad < 0) {
                    int padPreix = 1;
                    for (int i = 0; i <= name.length; i++) {
                        if(padPreix > 0) {
                            namePadPreix = [name substringToIndex:i];
                            int namePadPreixLenght = [Tools textLength:namePadPreix];
                            padPreix = [Tools textLength:qtyLoc] - namePadPreixLenght;
                        }else {
                            nameSuffix = [name substringFromIndex:i - 1];
                            break;
                        }
                    }
                }
                
                // 名称
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:00 andNH:00]];
                [dataM appendData: [namePadPreix dataUsingEncoding: gbkEncoding]];
                
                // 数量
                NSString *qty = [NSString stringWithFormat:@"   %@[%@]", [Tools  OneDecimal:getOupputItemM.oUTPUTQTY], getOupputItemM.oUTPUTUOM];
                [dataM appendData: [qty dataUsingEncoding: gbkEncoding]];
                
                // 金额
                NSString *price = [NSString stringWithFormat:@"￥%.2f", [getOupputItemM.oRGPRICE floatValue] - [getOupputItemM.mJPRICE floatValue]];
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:200 andNH:01]];
                [dataM appendData: [price dataUsingEncoding: gbkEncoding]];
                [dataM appendData:[XYCommand printAndFeedLine]];
                
                if(pad < 0) {
                    // 名称(第二行)
                    [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:25 andNH:00]];
                    [dataM appendData: [nameSuffix dataUsingEncoding: gbkEncoding]];
                    [dataM appendData:[XYCommand printAndFeedLine]];
                }
            }
        }
    }else if(_order){
        
        // 订单
        if(_order.OrderDetails.count > 0) {
            
            for (int i = 0; i < _order.OrderDetails.count; i++) {
                
                OrderDetailModel *m = _order.OrderDetails[i];
                NSString *name = [NSString stringWithFormat:@"%d.%@", i + 1, m.PRODUCT_NAME];
                // 产品名称太长，分两行
                NSString *namePadPreix = name;
                NSString *nameSuffix = @"";
                
                // 数量占位t符
                NSString *qtyLoc = @"abcdefgheijklnmopqrstuv";
                int nameLenght = [Tools textLength:namePadPreix];
                int pad = [Tools textLength:qtyLoc] - nameLenght;
                if(pad > 0){
                    for (int i = 0; i < pad; i++) {
                        namePadPreix = [namePadPreix stringByAppendingFormat:@" "];
                    }
                }
                
                // 产品名称超过设置长度，自动换行
                if(pad < 0) {
                    int padPreix = 1;
                    for (int i = 0; i <= name.length; i++) {
                        if(padPreix > 0) {
                            namePadPreix = [name substringToIndex:i];
                            int namePadPreixLenght = [Tools textLength:namePadPreix];
                            padPreix = [Tools textLength:qtyLoc] - namePadPreixLenght;
                        }else {
                            nameSuffix = [name substringFromIndex:i - 1];
                            break;
                        }
                    }
                }
                
                // 名称
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:00 andNH:00]];
                [dataM appendData: [namePadPreix dataUsingEncoding: gbkEncoding]];
                
                // 数量
                NSString *qty = [NSString stringWithFormat:@"   %.1f[%@]", m.ISSUE_QTY, m.ORDER_UOM];
                [dataM appendData: [qty dataUsingEncoding: gbkEncoding]];
                
                // 金额
                NSString *price = [NSString stringWithFormat:@"￥%.2f", m.ACT_PRICE];
                [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:200 andNH:01]];
                [dataM appendData: [price dataUsingEncoding: gbkEncoding]];
                [dataM appendData:[XYCommand printAndFeedLine]];
                
                if(pad < 0) {
                    // 名称(第二行)
                    [dataM appendData:[XYCommand setAbsolutePrintXYitionWithNL:25 andNH:00]];
                    [dataM appendData: [nameSuffix dataUsingEncoding: gbkEncoding]];
                    [dataM appendData:[XYCommand printAndFeedLine]];
                }
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
        totalPrice = [_getOupputDetailM.getOupputInfoModel.pRICE floatValue];
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
    
    if ([CUSTOM_OR_RECEIPT isEqualToString:@"回单联"]) {
        
        [dataM appendData:[XYCommand printAndFeedLine]];
        [dataM appendData: [@"客户签名：" dataUsingEncoding: gbkEncoding]];
        [dataM appendData:[XYCommand printAndFeedLine]];
    }
    
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

#pragma mark - XYSDKDelegate
- (void)XYdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList {
    
    NSMutableArray *dataArr = [NSMutableArray arrayWithArray:peripherals];
    int i = 0;
    for (CBPeripheral *peripheral in dataArr) {
        NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"w_peripheral.name"];
        if([name isEqualToString:peripheral.name]) {
            
            [self.manager XYconnectDevice:peripheral];
            self.manager.writePeripheral = peripheral;
            [Tools showAlert:self.view andTitle:@"连接成功"];
            i ++;
            break;
        }
    }
    if(i == 0) {
        
        [Tools showAlert:self.view andTitle:@"未找到打印机"];
    }
}

@end
