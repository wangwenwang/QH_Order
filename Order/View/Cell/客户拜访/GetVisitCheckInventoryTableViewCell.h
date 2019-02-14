//
//  GetVisitCheckInventoryTableViewCell.h
//  Order
//
//  Created by wenwang wang on 2019/2/14.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetVisitCheckInventoryTableViewCellDelegate <NSObject>

@optional
- (void)okOfGetVisitCheckInventoryTableViewCell:(NSUInteger)row andQty:(NSUInteger)qty;

@end

@interface GetVisitCheckInventoryTableViewCell : UITableViewCell

@property (weak, nonatomic) id<GetVisitCheckInventoryTableViewCellDelegate> delegate;

/// 产品名称
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@end
