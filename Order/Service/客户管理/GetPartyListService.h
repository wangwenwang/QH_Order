//
//  GetPartyListService.h
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

/// 获取客户列表（全部）
#import <Foundation/Foundation.h>



@protocol GetPartyListServiceDelegate <NSObject>

@optional
- (void)successOfGetPartyList:(nullable NSArray *)partys;

@optional
- (void)successOfGetPartyList_NoData;

@optional
- (void)failureOfGetPartyList:(nullable NSString *)msg;

@end


@interface GetPartyListService : NSObject

@property (weak, nonatomic, nullable) id <GetPartyListServiceDelegate> delegate;

- (void)GetPartyListByUserIdx:(nullable NSString *)strUserId andStrBusinessId:(nullable NSString *)strBusinessId;

@end
