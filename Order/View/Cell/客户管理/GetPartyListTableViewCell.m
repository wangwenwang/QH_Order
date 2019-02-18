//
//  GetPartyListTableViewCell.m
//  Order
//
//  Created by 凯东源 on 17/7/13.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "GetPartyListTableViewCell.h"

@interface GetPartyListTableViewCell ()

// 客户名称
@property (weak, nonatomic) IBOutlet UILabel *PARTY_NAME;

// 联系人
@property (weak, nonatomic) IBOutlet UILabel *CONTACT_PERSON;

// 联系电话
@property (weak, nonatomic) IBOutlet UILabel *CONTACT_TEL;

// 详细地址
@property (weak, nonatomic) IBOutlet UILabel *ADDRESS_INFO;

@end

@implementation GetPartyListTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}


- (void)setPartyM:(PartyModel *)partyM {
    
    _partyM = partyM;
    
    _PARTY_NAME.text = _partyM.PARTY_NAME;
    _CONTACT_PERSON.text = _partyM.CONTACT_PERSON;
    _CONTACT_TEL.text = _partyM.CONTACT_TEL;
    _ADDRESS_INFO.text = _partyM.ADDRESS_INFO;
}


- (IBAction)editOnclick {
    
    if([_delegate respondsToSelector:@selector(editOnclick:)]) {
        
        [_delegate editOnclick:self.tag];
    }
}

@end
