//
//  GetAppOutPutListService.h
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetOupputListModel.h"

@protocol GetAppOutPutListServiceDelegate <NSObject>

/// 出库列表 成功
@optional
- (void)successOfGetAppOutPutList:(nullable GetOupputListModel *)getOupputListM;

/// 出库列表 没有数据
@optional
- (void)successOfGetAppOutPutList_NoData;

/// 出库列表 失败
@optional
- (void)failureOfGetAppOutPutList:(nullable NSString *)msg;

@end

@interface GetAppOutPutListService : NSObject

@property (weak, nonatomic)id <GetAppOutPutListServiceDelegate> delegate;

- (void)GetAppOutPutList:(nullable NSString *)BUSINESS_IDX andADD_USER:(nullable NSString *)ADD_USER andStrPage:(NSInteger)strPage andStrPageCount:(NSInteger)strPageCount andStrPartyCode:(nullable NSString *)strPartyCode andStrPartyName:(nullable NSString *)strPartyName andStrOrdNo:(nullable NSString *)strOrdNo andStrStartTime:(nullable NSString *)strStartTime andStrEndTime:(nullable NSString *)strEndTime;

@end
