//
//  MergeOutputOrderService.h
//  Order
//
//  Created by wenwang wang on 2019/6/20.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol MergeOutputOrderServiceDelegate <NSObject>

/// 成功
@optional
- (void)successOfMergeOutputOrder;

/// 失败
@optional
- (void)failureOfMergeOutputOrder:(NSString * _Nullable)msg;

@end

@interface MergeOutputOrderService : NSObject

@property (weak, nonatomic, nullable)id <MergeOutputOrderServiceDelegate> delegate;

/**
 合并出库单，生成采购单
 
 @param orders  出库单号
 */
- (void)mergeOutputOrder:(nullable NSString *)outputNos;

@end

NS_ASSUME_NONNULL_END
