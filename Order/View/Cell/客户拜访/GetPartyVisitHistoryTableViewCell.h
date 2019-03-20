//
//  GetPartyVisitHistoryTableViewCell.h
//  Order
//
//  Created by wenwang wang on 2019/3/19.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetPartyVisitItemModel.h"

@protocol GetPartyVisitHistoryTableViewCellDelegate <NSObject>

/// 继续拜访
- (void)continueOnclick:(NSUInteger)row;

@end

@interface GetPartyVisitHistoryTableViewCell : UITableViewCell


@property (weak, nonatomic) id <GetPartyVisitHistoryTableViewCellDelegate> delegate;

@property (strong, nonatomic)GetPartyVisitItemModel *getPartyVisitItemM;

@end
