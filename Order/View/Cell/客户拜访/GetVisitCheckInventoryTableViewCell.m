//
//  GetVisitCheckInventoryTableViewCell.m
//  Order
//
//  Created by wenwang wang on 2019/2/14.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetVisitCheckInventoryTableViewCell.h"

@interface GetVisitCheckInventoryTableViewCell()

@property (weak, nonatomic) IBOutlet UITextField *qty;

@end

@implementation GetVisitCheckInventoryTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (IBAction)ok {
    if([_delegate respondsToSelector:@selector(okOfGetVisitCheckInventoryTableViewCell:andQty:)]) {
        [_delegate okOfGetVisitCheckInventoryTableViewCell:self.tag andQty:[_qty.text integerValue]];
    }
}

@end
