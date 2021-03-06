//
//  GetInputInfoTableViewCell.m
//  Order
//
//  Created by 凯东源 on 2017/8/22.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "GetInputInfoTableViewCell.h"
#import "Tools.h"

@interface GetInputInfoTableViewCell ()

// 产品代码
@property (weak, nonatomic) IBOutlet UILabel *PRODUCT_NO;

// 产品名称
@property (weak, nonatomic) IBOutlet UILabel *PRODUCT_NAME;

// 出库数量
@property (weak, nonatomic) IBOutlet UILabel *OUTPUT_QTY;

// 出库重量
@property (weak, nonatomic) IBOutlet UILabel *OUTPUT_WEIGHT;

// 出库体积
@property (weak, nonatomic) IBOutlet UILabel *OUTPUT_VOLUME;

// 产品原价
@property (weak, nonatomic) IBOutlet UILabel *ORG_PRICE;

// 付款价
@property (weak, nonatomic) IBOutlet UILabel *payPriceLabel;

// 总价
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@end

@implementation GetInputInfoTableViewCell


- (void)awakeFromNib {
    
    [super awakeFromNib];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}


- (void)setInputItemM:(InputItemModel *)inputItemM {
    
    // 重量
    NSString *OUTPUT_WEIGHT = [NSString stringWithFormat:@"%f", [inputItemM.pRODUCTWEIGHT floatValue] * [inputItemM.iNPUTQTY intValue]];
    // 体积
    NSString *OUTPUT_VOLUME = [NSString stringWithFormat:@"%f", [inputItemM.pRODUCTVOLUME floatValue] * [inputItemM.iNPUTQTY intValue]];
    
    _PRODUCT_NO.text = inputItemM.pRODUCTNO;
    _PRODUCT_NAME.text = inputItemM.pRODUCTNAME;
    _OUTPUT_QTY.text = [NSString stringWithFormat:@"%@%@", [Tools OneDecimal:inputItemM.iNPUTQTY], inputItemM.iNPUTUOM];
    _OUTPUT_WEIGHT.text = [Tools TwoDecimal:OUTPUT_WEIGHT];
    _OUTPUT_VOLUME.text = [Tools TwoDecimal:OUTPUT_VOLUME];
    _ORG_PRICE.text = [Tools TwoDecimal:inputItemM.pRICE];
    
    // 付款价
    _payPriceLabel.text = [Tools TwoDecimal:inputItemM.pRICE];
    // 总价
    _totalPriceLabel.text = [Tools TwoDecimal:inputItemM.sUM];
}

@end
