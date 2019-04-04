//
//  PrintVC.h
//  Order
//
//  Created by wenwang wang on 2019/4/3.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetOupputDetailModel.h"
#import "OrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PrintVC : UIViewController

// 销售出库单
@property (strong, nonatomic) GetOupputDetailModel *getOupputDetailM;

// 采购入库单
@property (strong, nonatomic) OrderModel *order;
@property (strong, nonatomic) NSArray *arrGoods;
@property (strong, nonatomic) NSArray *arrGitfs;

@end

NS_ASSUME_NONNULL_END
