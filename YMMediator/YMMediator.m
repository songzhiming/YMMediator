//
//  YMMediator.m
//  YMMediatorDemo
//
//  Created by 宋志明 on 16/11/29.
//  Copyright © 2016年 宋志明. All rights reserved.
//

#import "YMMediator.h"

@implementation YMMediator


+ (YMMediator *)shareInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance =  [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.urlScheme = @"";
    }
    return self;
}


// URL = scheme://Target/action?params  按照这个规则  http://nshipster.cn/nsurl/
- (id)remoteActionWithUrl:(NSURL *)url
               completion:(void(^)(NSDictionary *info))completion
{
    // 验证
    if (![url.scheme isEqualToString:self.urlScheme]) {
        // 这里就是针对远程app调用404的简单处理了，根据不同app的产品经理要求不同，你们可以在这里自己做需要的逻辑
        return @(NO);
    }
    // 获取参数
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSString *query = [url query];
    NSArray *queryArr = [query componentsSeparatedByString:@"&"];
    for (NSString *item in queryArr) {
        NSArray *p = [item componentsSeparatedByString:@"="];
        if (p.count < 2) {
            continue;
        }else{
            [params setObject:p.lastObject forKey:p.firstObject];
        }
    }
    //
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    id result = [self localTarget:url.host action:actionName params:params];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        }else{
            completion(nil);
        }
    }
    return result;
}


- (id)localTarget:(NSString *)targetName
           action:(NSString *)actionName
           params:(NSDictionary *)params
{
    NSString *targetClassString = targetName;
    NSString *actionString = actionName;
    Class targetClass = NSClassFromString(targetClassString);
    id target = [[targetClass alloc] init];
    SEL action = NSSelectorFromString(actionString);
    if (target == nil) {
        // 这里是处理无响应请求的地方之一，这个demo做得比较简单，如果没有可以响应的target，就直接return了。实际开发过程中是可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求的
        return nil;
    }
    if ([target respondsToSelector:action]) {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        return [target performSelector:action withObject:params];
    } else {
        // 这里也是处理无响应请求的地方，在notFound都没有的时候，这个demo是直接return了。实际开发过程中，可以用前面提到的固定的target顶上的。
        return nil;
    }
}

@end
