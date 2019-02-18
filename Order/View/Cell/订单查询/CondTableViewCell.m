//
//  CondTableViewCell.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "CondTableViewCell.h"

@implementation CondTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (IBAction)delOnclick {
    
    if([_delegate respondsToSelector:@selector(delOnclickOfCondTableViewCell:)]) {
        
        [_delegate delOnclickOfCondTableViewCell:self.tag];
    }
}

@end
