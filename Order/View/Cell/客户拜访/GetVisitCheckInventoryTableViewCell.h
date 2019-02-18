//
//  GetVisitCheckInventoryTableViewCell.h
//  Order
//
//  Created by wenwang wang on 2019/2/14.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"

@protocol GetVisitCheckInventoryTableViewCellDelegate <NSObject>

@optional
- (void)okOfGetVisitCheckInventoryTableViewCell:(NSUInteger)row andQty:(NSUInteger)qty;

@end

@interface GetVisitCheckInventoryTableViewCell : UITableViewCell

@property (weak, nonatomic) id<GetVisitCheckInventoryTableViewCellDelegate> delegate;

@property (strong, nonatomic) ProductModel *productM;

@end
