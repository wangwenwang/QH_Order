//
//  KPIExamViewController.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "KPIExamViewController.h"
#import <LMProgressView.h>
#import "GetTargetByUserIdxService.h"
#import "AppDelegate.h"
#import <MBProgressHUD.h>
#import "Tools.h"

@interface KPIExamViewController ()<GetTargetByUserIdxServiceDelegate>

// 总件数（箱也认为件，瓶要通过转换率转为件）
@property (weak, nonatomic) IBOutlet UIView *orderSumQtyContainerView;

// 总金额
@property (weak, nonatomic) IBOutlet UIView *orderSumAmountContainerView;

// 总件数考核 （箱也认为件，瓶要通过转换率转为件）
@property (nonatomic, strong)LMProgressView *progressView_qty;

// 总金额考核
@property (nonatomic, strong)LMProgressView *progressView_amount;

// 目标销量
@property (weak, nonatomic) IBOutlet UILabel *SalesVolume;

// 已达到销量
@property (weak, nonatomic) IBOutlet UILabel *CompleteSalesVolume;

// 目标金额
@property (weak, nonatomic) IBOutlet UILabel *AmountMoney;

// 已达到金额
@property (weak, nonatomic) IBOutlet UILabel *CompleteAmountMoney;

@property (strong, nonatomic) GetTargetByUserIdxService *service;

@property (strong, nonatomic) AppDelegate *app;

@end

@implementation KPIExamViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[GetTargetByUserIdxService alloc] init];
        _service.delegate = self;
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initUI];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service GetTargetByUserIdx:_app.user.IDX andStrBusinessId:_app.business.BUSINESS_IDX];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - 功能函数
- (void)initUI {
    
    _SalesVolume.text = @"0件";
    _CompleteSalesVolume.text = @"0件";
    _AmountMoney.text = @"0元";
    _CompleteAmountMoney.text = @"0元";
}

- (void)addProgressView:(float)qty andAmount:(float)amo {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_orderSumQtyContainerView addSubview:self.progressView_qty];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                for (float i = 0; i < qty ; i += 0.01) {
                    usleep(30000);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _progressView_qty.progress = i;
                    });
                }
            });
            
            [_orderSumAmountContainerView addSubview:self.progressView_amount];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                for (float i = 0; i < amo ; i += 0.01) {
                    usleep(30000);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _progressView_amount.progress = i;
                    });
                }
            });
        });
    });
}

#pragma mark - GET方法
- (LMProgressView *)progressView_qty {
    if(!_progressView_qty) {
        
        _progressView_qty = [[LMProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_orderSumQtyContainerView.frame), CGRectGetHeight(_orderSumQtyContainerView.frame))];
        _progressView_qty.textColor = RGB(40, 156, 70);
        _progressView_qty.font = [UIFont systemFontOfSize:17];
    }
    return _progressView_qty;
}

- (LMProgressView *)progressView_amount {
    if(!_progressView_amount) {
        
        _progressView_amount = [[LMProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_orderSumQtyContainerView.frame), CGRectGetHeight(_orderSumQtyContainerView.frame))];
        _progressView_amount.textColor = RGB(40, 156, 70);
        _progressView_amount.font = [UIFont systemFontOfSize:17];
    }
    return _progressView_amount;
}

#pragma mark - GetTargetByUserIdxServiceDelegate

- (void)successOfGetTargetByUserIdx:(KPIExamModel *)KPIExamM {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    _SalesVolume.text = [NSString stringWithFormat:@"%@件", KPIExamM.salesVolume];
    _CompleteSalesVolume.text = [NSString stringWithFormat:@"%@件", KPIExamM.completeSalesVolume];
    _AmountMoney.text = [NSString stringWithFormat:@"%@元", KPIExamM.amountMoney];
    _CompleteAmountMoney.text = [NSString stringWithFormat:@"%@元", KPIExamM.completeAmountMoney];
    
    float qty = [KPIExamM.completeSalesVolume floatValue] / [KPIExamM.salesVolume floatValue];
    float amo = [KPIExamM.completeAmountMoney floatValue] / [KPIExamM.amountMoney floatValue];
    
    [self addProgressView:qty andAmount:amo];
}

- (void)successOfGetTargetByUserIdx_NoData {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:@"未设置考核"];
    
    [self addProgressView:1.0 andAmount:1.0];
}

- (void)failureOfGetTargetByUserIdx:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];

    [self addProgressView:1.0 andAmount:1.0];
}

@end
