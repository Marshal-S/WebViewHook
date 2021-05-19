//
//  LSURLProtocol.m
//  URLProtocolDemo
//
//  Created by Marshal on 2021/5/10.
//

#import "LSURLProtocol.h"

@interface LSURLProtocol ()



@end

@implementation LSURLProtocol

//是否能够处理给定的请求，自行出行返回YES，否则返回NO
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSLog(@"%@", request.URL.absoluteString);
    //拦截百度的logo
    NSArray *blackList = @[@"jpeg", @"png", @"jpg"];
    if ([request.URL.absoluteString isEqualToString:@"https://www.baidu.com/img/flexible/logo/plus_logo_web_2.png"]) {
        //屏蔽单个url
        return YES;
    }else if ([blackList containsObject:request.URL.pathExtension]) {
        //拦截掉一类数据例如图片
        return YES;
    }
//    else if ([request.URL.absoluteString containsString:@"www.baidu.com"]) {
//        //是否包含某个url，或者其他，可以屏蔽一类网站
//        return YES;
//    }
    return NO;
}

//必须实现，规范化URL请求，一般返回request
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

//用于检测两个请求是缓存等效的，则为YES，否则为NO
//+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
//    return [super requestIsCacheEquivalent:a toRequest:b];
//}

- (void)startLoading {
    //拦截后加载请求，可以在这里调整发起自己的网络请求
    NSArray *blackList = @[@"jpeg", @"png", @"jpg"];
    if ([self.request.URL.absoluteString isEqualToString:@"https://www.baidu.com/img/flexible/logo/plus_logo_web_2.png"]) {
        NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpeg"]];
        [self.client URLProtocol:self didLoadData:imgData];
    }else if ([blackList containsObject:self.request.URL.pathExtension]) {
        //将拦截的图片替换掉
        NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpeg"]];
        [self.client URLProtocol:self didLoadData:imgData];
    }
//    else if ([self.request.URL.absoluteString containsString:@"www.baidu.com"]) {
//        //是否包含某个url，或者其他，可以屏蔽一类网站
//
//    }
}

- (void)stopLoading {
    //
}

@end
