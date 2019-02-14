//
//  GetVisitCheckInventoryOkTableViewCell.h
//  Order
//
//  Created by wenwang wang on 2019/2/14.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetVisitCheckInventoryOkTableViewCellDelegate <NSObject>

@optional
- (void)okOfGetVisitCheckInventoryOkTableViewCell:(NSUInteger)row;

@end

@interface GetVisitCheckInventoryOkTableViewCell : UITableViewCell

@property (weak, nonatomic) id<GetVisitCheckInventoryOkTableViewCellDelegate> delegate;

/// 产品名称
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@end
