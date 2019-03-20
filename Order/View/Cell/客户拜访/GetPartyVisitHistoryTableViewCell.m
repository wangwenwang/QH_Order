//
//  GetPartyVisitHistoryTableViewCell.m
//  Order
//
//  Created by wenwang wang on 2019/3/19.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetPartyVisitHistoryTableViewCell.h"
#import "Tools.h"

@interface GetPartyVisitHistoryTableViewCell ()

// 客户名称
@property (weak, nonatomic) IBOutlet UILabel *PARTY_NAME;

// 拜访时间
@property (weak, nonatomic) IBOutlet UILabel *ADD_DATE;

// 拜访状态
@property (weak, nonatomic) IBOutlet UILabel *VISIT_STATES;

// 继续拜访
@property (weak, nonatomic) IBOutlet UIView *ContinueVisitView;

@end

@implementation GetPartyVisitHistoryTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}


- (IBAction)continueOnclick {
    
    if([_delegate respondsToSelector:@selector(continueOnclick:)]) {
        
        [_delegate continueOnclick:self.tag];
    }
}


- (void)setGetPartyVisitItemM:(GetPartyVisitItemModel *)getPartyVisitItemM {
    
    _PARTY_NAME.text = getPartyVisitItemM.pARTYNAME;
    if(![getPartyVisitItemM.vISITDATE isEqualToString:@""]) {
        
        _ADD_DATE.text = [NSString stringWithFormat:@"拜访时间: %@", getPartyVisitItemM.vISITDATE];
    }else {
        
        _ADD_DATE.text = @"";
    }
    
    if([[Tools getVISIT_STATES:getPartyVisitItemM.vISITSTATES] isEqualToString:@"未拜访"]) {
        
        [_VISIT_STATES setHidden:NO];
        [_ContinueVisitView setHidden:YES];
        [_VISIT_STATES setText:@"未拜访"];
        [_VISIT_STATES setTextColor:[UIColor redColor]];
    }else if([[Tools getVISIT_STATES:getPartyVisitItemM.vISITSTATES] isEqualToString:@"拜访中"]) {
        
        [_VISIT_STATES setHidden:YES];
        [_ContinueVisitView setHidden:NO];
        [_VISIT_STATES setText:@"拜访中"];
        [_VISIT_STATES setTextColor:[UIColor orangeColor]];
    }else if([[Tools getVISIT_STATES:getPartyVisitItemM.vISITSTATES] isEqualToString:@"已拜访"]) {
        
        [_VISIT_STATES setHidden:NO];
        [_ContinueVisitView setHidden:YES];
        [_VISIT_STATES setText:@"已拜访"];
        [_VISIT_STATES setTextColor:RGB(35, 120, 58)];
    }
}

@end
