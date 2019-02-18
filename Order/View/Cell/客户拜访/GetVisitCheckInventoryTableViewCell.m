//
//  GetVisitCheckInventoryTableViewCell.m
//  Order
//
//  Created by wenwang wang on 2019/2/14.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetVisitCheckInventoryTableViewCell.h"
#import "Tools.h"

@interface GetVisitCheckInventoryTableViewCell()

// 产品名称
@property (weak, nonatomic) IBOutlet UILabel *name;

// 数量
@property (weak, nonatomic) IBOutlet UITextField *qty;

// 单位
@property (weak, nonatomic) IBOutlet UILabel *uom;

@end

@implementation GetVisitCheckInventoryTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)setProductM:(ProductModel *)productM {
    
    _name.text = productM.PRODUCT_NAME;
    NSString *uom;
    if([Tools hasBASE_RATE:productM.BASE_RATE]) {
        uom = productM.PACK_UOM;
    }else {
        uom = productM.PRODUCT_UOM;
    }
    _uom.text = uom;
}

- (IBAction)ok {
    if([_delegate respondsToSelector:@selector(okOfGetVisitCheckInventoryTableViewCell:andQty:)]) {
        [_delegate okOfGetVisitCheckInventoryTableViewCell:self.tag andQty:[_qty.text integerValue]];
    }
}

@end
