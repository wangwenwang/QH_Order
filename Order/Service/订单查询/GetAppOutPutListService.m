//
//  GetAppOutPutListService.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "GetAppOutPutListService.h"
#import "AppDelegate.h"
#import <AFNetworking.h>

#define kAPI_NAME @"获取出库单信息"

@interface GetAppOutPutListService ()

@property (strong, nonatomic) AppDelegate *app;

@end

@implementation GetAppOutPutListService

- (instancetype)init {
    
    if (self = [super init]) {
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)GetAppOutPutList:(nullable NSString *)BUSINESS_IDX andADD_USER:(nullable NSString *)ADD_USER andStrPage:(NSInteger)strPage andStrPageCount:(NSInteger)strPageCount andStrPartyCode:(nullable NSString *)strPartyCode andStrPartyName:(nullable NSString *)strPartyName andStrOrdNo:(nullable NSString *)strOrdNo andStrStartTime:(nullable NSString *)strStartTime andStrEndTime:(nullable NSString *)strEndTime {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                BUSINESS_IDX, @"BUSINESS_IDX",
                                ADD_USER, @"ADD_USER",
                                @(strPage), @"strPage",
                                @(strPageCount), @"strPageCount",
                                strPartyCode, @"strPartyCode",
                                strPartyName, @"strPartyName",
                                strOrdNo, @"strOrdNo",
                                strStartTime, @"strStartTime",
                                strEndTime, @"strEndTime",
                                @"", @"strLicense",
                                nil];
    
    NSLog(@"接口:%@请求%@参数：%@", kAPI_NAME, API_GetAppOutPutList, parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_GetAppOutPutList parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"%@|请求成功---%@", kAPI_NAME, responseObject);
        int _type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        
        if(_type == 1) {
            
            GetOupputListModel *getOupputListM = [[GetOupputListModel alloc] initWithDictionary:responseObject[@"result"]];
            
            if(getOupputListM.getOupputModel.count > 0) {
                
                [self successOfGetAppOutPutList:getOupputListM];
            } else {
                
                [self successOfGetAppOutPutList_NoData];
            }
        } else {
            
            [self failureOfGetAppOutPutList:msg];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@|请求失败:%@", kAPI_NAME, error);
        [self failureOfGetAppOutPutList:nil];
    }];
}


// 成功
- (void)successOfGetAppOutPutList:(nullable GetOupputListModel *)getOupputListM {
    
    if([_delegate respondsToSelector:@selector(successOfGetAppOutPutList:)]) {

        [_delegate successOfGetAppOutPutList:getOupputListM];
    }
}


// 没有数据
- (void)successOfGetAppOutPutList_NoData {
    
    if([_delegate respondsToSelector:@selector(successOfGetAppOutPutList_NoData)]) {

        [_delegate successOfGetAppOutPutList_NoData];
    }
}


// 失败
- (void)failureOfGetAppOutPutList:(nullable NSString *)msg {
    
    if([_delegate respondsToSelector:@selector(failureOfGetAppOutPutList:)]) {
        
        [_delegate failureOfGetAppOutPutList:msg];
    }
}

@end
