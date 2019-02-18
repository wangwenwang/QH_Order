//
//  GetPartyListService.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetPartyListService.h"

#import <AFNetworking.h>

#import "PartyModel.h"

#define kAPI_NAME @"获取客户列表（全部）"

@implementation GetPartyListService

- (void)GetPartyListByUserIdx:(nullable NSString *)strUserId andStrBusinessId:(nullable NSString *)strBusinessId {
    
    NSDictionary *parameters = @{
                                 @"strUserId" : strUserId,
                                 @"strBusinessId" : strBusinessId,
                                 @"strLicense" : @""
                                 };
    
    NSLog(@"接口:%@请求%@参数：%@", API_GetPartyListByUserIdx, kAPI_NAME, parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_GetPartyListByUserIdx parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@|请求成功---%@", kAPI_NAME, responseObject);
        
        int type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        
        if(type == 1) {
            
            NSMutableArray *partys = [[NSMutableArray alloc] init];
            NSArray *arrResult = responseObject[@"result"];
            if([arrResult isKindOfClass:[NSArray class]]) {
                for(int i = 0; i < arrResult.count; i++) {
                    NSDictionary *dict = arrResult[i];
                    PartyModel *m = [[PartyModel alloc] init];
                    [m setDict:dict];
                    [partys addObject:m];
                }
                if([_delegate respondsToSelector:@selector(successOfGetPartyList:)]) {
                    [_delegate successOfGetPartyList:partys];
                }
            }else {
                [self failureOfGetPartyList:msg];
            }
        }else {
            
            [self failureOfGetPartyList:msg];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@|请求失败:%@", kAPI_NAME, error);
        [self failureOfGetPartyList:[NSString stringWithFormat:@"请求%@失败", kAPI_NAME]];
    }];
}


// 成功
- (void)successOfGetPartyList:(nullable NSArray *)partys {
    
    if([_delegate respondsToSelector:@selector(successOfGetPartyList:)]) {
        
        [_delegate successOfGetPartyList:partys];
    }
}


// 没有数据
- (void)successOfGetPartyList_NoData {
    
    if([_delegate respondsToSelector:@selector(successOfGetPartyList_NoData)]) {
        
        [_delegate successOfGetPartyList_NoData];
    }
}


// 失败
- (void)failureOfGetPartyList:(nullable NSString *)msg {
    
    if([_delegate respondsToSelector:@selector(failureOfGetPartyList:)]) {
        
        [_delegate failureOfGetPartyList:msg];
    }
}

@end
