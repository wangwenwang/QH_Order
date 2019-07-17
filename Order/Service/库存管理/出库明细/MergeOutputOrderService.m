//
//  MergeOutputOrderService.m
//  Order
//
//  Created by wenwang wang on 2019/6/20.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "MergeOutputOrderService.h"
#import <AFNetworking.h>

#define kAPI_NAME @"合并出库单，生成采购单"

@implementation MergeOutputOrderService

- (void)mergeOutputOrder:(nullable NSString *)outputNos {
    
    NSDictionary *parameters = @{
                                 @"outputNos" : outputNos,
                                 @"strLicense" : @"",
                                 };
    
    NSLog(@"接口:%@请求%@参数：%@", API_MerOutGenIn, kAPI_NAME, parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_MerOutGenIn parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"请求%@成功---%@", kAPI_NAME, responseObject);
        
        int type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        if(type == 1) {
            
            [self successOfMergeOutputOrder];
        }else {
            
            [self failureOfMergeOutputOrder:msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"请求%@失败:%@", kAPI_NAME, error);
        [self failureOfMergeOutputOrder:[NSString stringWithFormat:@"请求%@失败", kAPI_NAME]];
    }];
}


// 成功
- (void)successOfMergeOutputOrder {
    
    if([_delegate respondsToSelector:@selector(successOfMergeOutputOrder)]) {
        
        [_delegate successOfMergeOutputOrder];
    }
}


// 失败
- (void)failureOfMergeOutputOrder:(nullable NSString *)msg {
    
    if([_delegate respondsToSelector:@selector(failureOfMergeOutputOrder:)]) {
        
        [_delegate failureOfMergeOutputOrder:msg];
    }
}

@end
