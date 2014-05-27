//
//  skyFielDown.h
//  文件下载
//
//  Created by sky on 14-4-29.
//  Copyright (c) 2014年 sky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface skyFielDown : NSObject

- (void)fileDownWithURL:(NSString *)urlStr completion:(void(^)(UIImage * img))completion;

@end
