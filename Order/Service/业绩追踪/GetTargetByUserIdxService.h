//
//  GetTargetByUserIdxService.h
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPIExamModel.h"


@protocol GetTargetByUserIdxServiceDelegate <NSObject>

/// 获取KPI考核 成功
@optional
- (void)successOfGetTargetByUserIdx:(nullable KPIExamModel *)KPIExamM;

/// 获取KPI考核 没有数据
@optional
- (void)successOfGetTargetByUserIdx_NoData;

/// 获取KPI考核 失败
@optional
- (void)failureOfGetTargetByUserIdx:(nullable NSString *)msg;

@end

@interface GetTargetByUserIdxService : NSObject

@property (weak, nonatomic)id <GetTargetByUserIdxServiceDelegate> delegate;

- (void)GetTargetByUserIdx:(nullable NSString *)strUserId andStrBusinessId:(nullable NSString *)strBusinessId;

@end
