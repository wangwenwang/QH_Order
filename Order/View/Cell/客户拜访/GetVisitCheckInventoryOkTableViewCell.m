//
//  GetVisitCheckInventoryOkTableViewCell.m
//  Order
//
//  Created by wenwang wang on 2019/2/14.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetVisitCheckInventoryOkTableViewCell.h"

@implementation GetVisitCheckInventoryOkTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)del {
    if([_delegate respondsToSelector:@selector(okOfGetVisitCheckInventoryOkTableViewCell:)]) {
        [_delegate okOfGetVisitCheckInventoryOkTableViewCell:self.tag];
    }
}

@end
