//
//  Store_GetOupputListService.m
//  Order
//
//  Created by 凯东源 on 2017/8/18.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "Store_GetOupputListService.h"
#import "AppDelegate.h"
#import <AFNetworking.h>

@interface Store_GetOupputListService ()

@property (strong, nonatomic) AppDelegate *app;

@end

@implementation Store_GetOupputListService


- (instancetype)init {
    
    if (self = [super init]) {
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}


- (void)GetOupputList:(nullable NSString *)addressIDX andstrPage:(NSInteger)strPage andstrPageCount:(NSInteger)strPageCount andBUSINESS_IDX:(nullable NSString *)BUSINESS_IDX {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                addressIDX, @"ADD_USER",
                                @(strPage), @"strPage",
                                @(strPageCount), @"strPageCount",
                                BUSINESS_IDX, @"BUSINESS_IDX",
                                @"", @"strLicense",
                                nil];
    
    NSLog(@"请求出库列表参数：%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_GetOupputList parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求出库列表成功---%@", responseObject);
        int _type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        
        if(_type == 1) {
            
            GetOupputListModel *getOupputListM = [[GetOupputListModel alloc] initWithDictionary:responseObject[@"result"]];
            
            if(getOupputListM.getOupputModel.count > 0) {
                
                [self successOfGetOupputList:getOupputListM];
            } else {
                
                [self successOfGetOupputList_NoData];
            }
        } else {
            
            [self failureOfGetOupputList:msg];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求出库列表失败:%@", error);
        [self failureOfGetOupputList:nil];
    }];
}


// 成功
- (void)successOfGetOupputList:(nullable GetOupputListModel *)getOupputListM {
    
    if([_delegate respondsToSelector:@selector(successOfGetOupputList:)]) {
        
        [_delegate successOfGetOupputList:getOupputListM];
    }
}


// 没有数据
- (void)successOfGetOupputList_NoData {
    
    if([_delegate respondsToSelector:@selector(successOfGetOupputList_NoData)]) {
        
        [_delegate successOfGetOupputList_NoData];
    }
}


// 失败
- (void)failureOfGetOupputList:(nullable NSString *)msg {
    
    if([_delegate respondsToSelector:@selector(failureOfGetOupputList:)]) {
        
        [_delegate failureOfGetOupputList:msg];
    }
}


- (void)GetVisitAppOrder:(nullable NSString *)strVisitIdx andStrType:(nullable NSString *)strType {
    
    NSDictionary *parameters = @{
                                 @"strVisitIdx": strVisitIdx,
                                 @"strType" : strType,
                                 @"strLicense": @""
                                 };
    
    NSLog(@"请求出库列表参数：%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_GetVisitAppOrder parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求出库列表成功---%@", responseObject);
        int _type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        
        if(_type == 1) {
            
            GetOupputListModel *getOupputListM = [[GetOupputListModel alloc] initWithDictionary:responseObject[@"result"][0]];
            
            if(getOupputListM.getOupputModel.count > 0) {
                
                [self successOfGetOupputList:getOupputListM];
            } else {
                
                [self successOfGetOupputList_NoData];
            }
        } else {
            
            [self failureOfGetOupputList:msg];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求出库列表失败:%@", error);
        [self failureOfGetOupputList:nil];
    }];
}

- (void)GetVisitAppOrde_AGENT:(nullable NSString *)strVisitIdx andStrType:(nullable NSString *)strType {
    
    NSDictionary *parameters = @{
                                 @"strVisitIdx": strVisitIdx,
                                 @"strType" : strType,
                                 @"strLicense": @""
                                 };
    
    NSLog(@"请求出库列表参数：%@", parameters);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_GetVisitAppOrder parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求出库列表成功---%@", responseObject);
        int _type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        
        if(_type == 1) {
            
            CheckOrderListModel *CheckOrderListM = [[CheckOrderListModel alloc] initWithDictionary:responseObject[@"result"][0]];
            
            if(CheckOrderListM.checkOrderItemModel.count > 0) {
                
                if([_delegate respondsToSelector:@selector(successOfGetOupputList_CheckOrder:)]) {
                    
                    [_delegate successOfGetOupputList_CheckOrder:CheckOrderListM];
                }
            } else {
                
                [self successOfGetOupputList_NoData];
            }
        } else {
            
            [self failureOfGetOupputList:msg];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求出库列表失败:%@", error);
        [self failureOfGetOupputList:nil];
    }];
}

@end
