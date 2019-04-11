//
//  GetPartyVisitListTableViewCell.m
//  Order
//
//  Created by wenwang wang on 2018/10/30.
//  Copyright © 2018年 凯东源. All rights reserved.
//

#import "GetPartyVisitListTableViewCell.h"
#import "Tools.h"

@interface GetPartyVisitListTableViewCell ()

// 联系人
@property (weak, nonatomic) IBOutlet UILabel *CONTACTS;

// 联系电话
@property (weak, nonatomic) IBOutlet UILabel *CONTACTS_TEL;

// 拜访时间
@property (weak, nonatomic) IBOutlet UILabel *VISIT_DATE;

// 客户名称
@property (weak, nonatomic) IBOutlet UILabel *PARTY_NAME;

// 客户地址
@property (weak, nonatomic) IBOutlet UILabel *PARTY_ADDRESS;

// 拜访状态
@property (weak, nonatomic) IBOutlet UILabel *VISIT_STATES;

// 编辑按钮宽
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *edit_width;

// 编辑按钮距左
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *edit_trailing;

// 查看拜访
@property (weak, nonatomic) IBOutlet UIView *checkView;

// 拜访
@property (weak, nonatomic) IBOutlet UIView *visitView;

// 拜访周期提示 本
@property (weak, nonatomic) IBOutlet UILabel *FREQUENCYPromptLabel;

// 拜访周期 周/月
@property (weak, nonatomic) IBOutlet UILabel *FREQUENCY;

// 已拜访次数
@property (weak, nonatomic) IBOutlet UILabel *VISIT_NUMBER;


@property (weak, nonatomic) IBOutlet UIView *cellView;

@end

@implementation GetPartyVisitListTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}


//- (IBAction)addStepOnclick {
//
//    if([_delegate respondsToSelector:@selector(addStepOnclick:)]) {
//
//        [_delegate addStepOnclick:self.tag];
//    }
//}


- (IBAction)showStepOnclick {
    
    if([_delegate respondsToSelector:@selector(showStepOnclick:)]) {
        
        [_delegate showStepOnclick:self.tag];
    }
}


- (IBAction)editOnclick {
    
    if([_delegate respondsToSelector:@selector(editOnclick:)]) {
        
        [_delegate editOnclick:self.tag];
    }
}


- (void)setGetPartyVisitItemM:(GetPartyVisitItemModel *)getPartyVisitItemM {
    
    _CONTACTS.text = getPartyVisitItemM.cONTACTS;
    _CONTACTS_TEL.text = getPartyVisitItemM.cONTACTSTEL;
    _PARTY_NAME.text = getPartyVisitItemM.pARTYNAME;
    _PARTY_ADDRESS.text = getPartyVisitItemM.pARTYADDRESS;
    if(![getPartyVisitItemM.vISITDATE isEqualToString:@""]) {
        
        _VISIT_DATE.text = [NSString stringWithFormat:@"上次拜访时间: %@", getPartyVisitItemM.vISITDATE];
    }else {
        
        _VISIT_DATE.text = @"";
    }
    
    if([getPartyVisitItemM.fREQUENCY isEqualToString:@""]) {
        
        [_FREQUENCYPromptLabel setText:@""];
    }else {
        
        [_FREQUENCYPromptLabel setText:@"本"];
    }
    
    [_FREQUENCY setText:getPartyVisitItemM.fREQUENCY];
    [_VISIT_NUMBER setText:getPartyVisitItemM.vISITNUMBER];
    
    
    NSString *birthdayStr = getPartyVisitItemM.vISITDATE;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *birthdayDate = [dateFormatter dateFromString:birthdayStr];
    // 拜访日期为今天且已拜访，显示绿色表示完成
    // 拜访日期为今天且拜访中，显示黄色表示正在进行中
    // 其它的显示红色表示未完成
    BOOL isToday= [Tools isToday:birthdayDate];
    if(isToday && [getPartyVisitItemM.vISITINGNUMBER intValue] <= 0) {
        
        [_cellView setBackgroundColor:RGBA(2, 167, 6, 0.3)];
    }else if(isToday && [getPartyVisitItemM.vISITINGNUMBER intValue] > 0) {
        
        [_cellView setBackgroundColor:RGBA(255, 227, 48, 0.3)];
    }else {
        
        [_cellView setBackgroundColor:RGBA(255, 75, 70, 0.3)];
    }
    
//    if([[Tools getVISIT_STATES:getPartyVisitItemM.vISITSTATES] isEqualToString:@"未拜访"]) {
//
//        [_VISIT_STATES setText:@"未拜访"];
//        [_VISIT_STATES setTextColor:[UIColor redColor]];
//    }else if([[Tools getVISIT_STATES:getPartyVisitItemM.vISITSTATES] isEqualToString:@"拜访中"]) {
//
//        [_VISIT_STATES setText:@"拜访中"];
//        [_VISIT_STATES setTextColor:[UIColor orangeColor]];
//    }else if([[Tools getVISIT_STATES:getPartyVisitItemM.vISITSTATES] isEqualToString:@"已拜访"]) {
//
//        [_VISIT_STATES setText:@"已拜访"];
//        [_VISIT_STATES setTextColor:RGB(35, 120, 58)];
//    }
}


- (void)setIsDisplayCheckBtn:(BOOL)isDisplayCheckBtn {
    
//    if(isDisplayCheckBtn) {
//
//        [_checkView setHidden:NO];
//    }else {
//
//        [_checkView setHidden:YES];
//    }
}


- (void)setIsDisplayVisitBtn:(BOOL)isDisplayVisitBtn {
    
//    if(isDisplayVisitBtn) {
//
//        _edit_width.constant = 68;
//        _edit_trailing.constant = 20;
//        [_visitView setHidden:NO];
//    }else {
//
//        _edit_width.constant = 0;
//        _edit_trailing.constant = 0;
//        [_visitView setHidden:YES];
//    }
}


@end
