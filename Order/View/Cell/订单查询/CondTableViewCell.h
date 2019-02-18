//
//  CondTableViewCell.h
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>

// 回调协议
@protocol CondTableViewCellDelegate <NSObject>

@optional
- (void)delOnclickOfCondTableViewCell:(NSUInteger)row;

@end

@interface CondTableViewCell : UITableViewCell

@property (weak, nonatomic) id<CondTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *name;

@end
