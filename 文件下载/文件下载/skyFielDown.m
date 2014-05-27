//
//  skyFielDown.m
//  文件下载
//
//  Created by sky on 14-4-29.
//  Copyright (c) 2014年 sky. All rights reserved.
//

#define kTimeOut 10
#define kByte 20480

#import "skyFielDown.h"
#import "NSString+Password.h"

@interface skyFielDown ()

@property (nonatomic,copy)NSString *cacheFilePath;

@property (nonatomic,copy)UIImage *cacheImage;

@end

@implementation skyFielDown
/*
- (NSString *)cacheFilePath
{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"123.png"];
//    NSLog(@"%@",filePath);
    return filePath;
}
*/
- (UIImage *)cacheImage
{
    if (_cacheImage == nil) {
        _cacheImage = [UIImage imageWithContentsOfFile:self.cacheFilePath];
    }
    NSLog(@"-------%@",_cacheImage);
    return _cacheImage;
}

- (void)setCacheFilePath:(NSString *)cacheFilePath
{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    cacheFilePath = [cacheFilePath MD5];
    filePath = [filePath stringByAppendingPathComponent:cacheFilePath];
    _cacheFilePath = filePath;
}

- (void)fileDownWithURL:(NSString *)urlStr completion:(void(^)(UIImage *img))completion
{
    __block NSString *str = urlStr;
    dispatch_queue_t q = dispatch_queue_create("sky", DISPATCH_QUEUE_SERIAL);
    dispatch_async(q, ^{
        str = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:str];
        //    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:kTimeOut];
        
        self.cacheFilePath = [url absoluteString];//取得绝对路径进行MD5加密
        
        long long responseFileSize = [self fileSize:url];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSDictionary *dic = [fm attributesOfItemAtPath:self.cacheFilePath error:nil];
        //    NSLog(@"%@",dic);
        long long cacheFileSize = [dic[@"NSFileSize"] longLongValue];
        
        if (cacheFileSize == responseFileSize) {
            //        NSLog(@"文件已存在！");
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"1-----%@----",[NSThread currentThread]);
                NSLog(@"%@",self.cacheImage);
                completion(self.cacheImage);
            });
            
            return;
        }
        
        long long fromByte = 0;
        long long toByte = 0;
        while (responseFileSize > kByte) {
            toByte = fromByte + kByte - 1;
            responseFileSize -= kByte;
            //        NSLog(@"%lld - %lld",fromByte,toByte);
            
            [self downloadFileWithURL:url fromByte:fromByte toByte:toByte];
            
            fromByte += kByte; //注意：一定要先把数据发送出来之后才能进行数值的累计，否则会出现错误！！！！！！！！
        }
        toByte = fromByte + responseFileSize - 1;
        //    NSLog(@"%lld - %lld",fromByte,toByte);
        [self downloadFileWithURL:url fromByte:fromByte toByte:toByte];
    });
}

- (void)downloadFileWithURL:(NSURL *)url fromByte:(long long)fBtye toByte:(long long) toByte
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:kTimeOut];
    NSString *range = [NSString stringWithFormat:@"Bytes=%lld-%lld",fBtye,toByte];
//    NSLog(@"%@",range);
    [request setValue:range forHTTPHeaderField:@"Range"];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    [self appendData:data];
//    NSLog(@"%@",response);
}

- (void)appendData:(NSData *)data
{
//    NSLog(@"%@",data);
    NSFileHandle *fp = [NSFileHandle fileHandleForWritingAtPath:self.cacheFilePath];
    if (!fp) {
        [data writeToFile:self.cacheFilePath atomically:YES];//创建文件
    }else {
        [fp seekToEndOfFile];
        [fp writeData:data];
        [fp closeFile];
    }
//    NSLog(@"操作成功");
}

- (long long)fileSize:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:kTimeOut];
    request.HTTPMethod = @"HEAD";

    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    NSLog(@"%lld",response.expectedContentLength);
    
    return response.expectedContentLength;
    
//    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        fileSize = response.expectedContentLength;
//    }];

}

@end
