//
//  GetTargetByUserIdxService.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetTargetByUserIdxService.h"

#import <AFNetworking.h>

#import "Tools.h"

#define kAPI_NAME @"获取KPI考核"

@implementation GetTargetByUserIdxService

- (void)GetTargetByUserIdx:(nullable NSString *)strUserId andStrBusinessId:(nullable NSString *)strBusinessId {
    
    NSDictionary *parameters = @{
                                 @"strUserId" : strUserId,
                                 @"strBusinessId" : strBusinessId,
                                 @"strLicense" : @""
                                 };
    
    NSLog(@"接口:%@请求%@参数：%@", kAPI_NAME, API_GetTargetByUserIdx, parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_GetTargetByUserIdx parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@|请求成功---%@", kAPI_NAME, responseObject);
    
        int type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        
        if(type == 1) {
            
            KPIExamModel *KPIExamM = [[KPIExamModel alloc] initWithDictionary:responseObject[@"result"][0]];
            [self successOfGetTargetByUserIdx:KPIExamM];
        } else if(type == -2) {
            
            [self successOfGetTargetByUserIdx_NoData];
        } else {
            
            [self failureOfGetTargetByUserIdx:msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@|请求失败:%@", kAPI_NAME, error);
        [self failureOfGetTargetByUserIdx:[NSString stringWithFormat:@"请求%@失败", kAPI_NAME]];
        
        
        
        
        
        // 模拟数量
//        NSString *str = @"{     \"type\": \"1\",     \"msg\": \"获取目标金额目标销量\",     \"result\": [{         \"SalesVolume\": \"100\",         \"AmountMoney\": \"100\",         \"CompleteSalesVolume\": \"70\",         \"CompleteAmountMoney\": \"90\"     }] }";
        
//                NSString *str = @"{\"type\":\"-2\",\"msg\":\"没有数据\",\"result\":[{\"msg\":\"\"}]}";

//        NSDictionary *dict = [Tools dictionaryWithJsonString:str];
//
//
//        int type = [dict[@"type"] intValue];
//        NSString *msg = dict[@"msg"];
//
//        KPIExamModel *KPIExamM = [[KPIExamModel alloc] initWithDictionary:dict[@"result"][0]];
//
//        if(type == 1) {
//
//            [self successOfGetTargetByUserIdx:KPIExamM];
//        } else if(type == -2) {
//
//            [self successOfGetTargetByUserIdx_NoData];
//        } else {
//
//            [self failureOfGetTargetByUserIdx:msg];
//        }
    }];
}


// 成功
- (void)successOfGetTargetByUserIdx:(KPIExamModel *)KPIExamM {
    
    if([_delegate respondsToSelector:@selector(successOfGetTargetByUserIdx:)]) {
        
        [_delegate successOfGetTargetByUserIdx:KPIExamM];
    }
}


// 无数据
- (void)successOfGetTargetByUserIdx_NoData {
    
    if([_delegate respondsToSelector:@selector(successOfGetTargetByUserIdx_NoData)]) {
        
        [_delegate successOfGetTargetByUserIdx_NoData];
    }
}


// 失败
- (void)failureOfGetTargetByUserIdx:(nullable NSString *)msg {
    
    if([_delegate respondsToSelector:@selector(failureOfGetTargetByUserIdx:)]) {
        
        [_delegate failureOfGetTargetByUserIdx:msg];
    }
}

@end
