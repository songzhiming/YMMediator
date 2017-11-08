//
//  YMMediator.h
//  YMMediatorDemo
//
//  Created by 宋志明 on 16/11/29.
//  Copyright © 2016年 宋志明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMMediator : NSObject

// 不可用
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
// 单例
+ (instancetype)shareInstance;

// url scheme 自己项目的scheme  默认为""; 如果有远程app调用此app，需要必须设置
@property (nonatomic, strong) NSString *urlScheme;

// 其他app 调用此app
- (id)remoteActionWithUrl:(NSURL *)url
               completion:(void(^)(NSDictionary *info))completion;

// 调用本地的组件
- (id)localTarget:(NSString *)targetName
           action:(NSString *)actionName
           params:(NSDictionary *)params;

@end
